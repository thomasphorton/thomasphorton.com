---
title: Using X.509 Certificates with ESP8266s
tags:
  - iot
  - esp8266
  - AWS
  - security
  - X.509
date: 2020-03-25 18:40:43
---

AWS IoT Core requires authentication via X.509 certificates. While loading them onto a Raspberry Pi is fairly straightforward using the AWS IoT SDK, it is a little more involved for ESPs (both 32s and 8266s). In this post, I'll walk through my current methodology for loading these certs onto an ESP8266 so you can start integrating your IoT projects with AWS IoT Core.

<!-- more -->

The methodology and code in this post is based off of the work of [Evandro Luis Copercini (github/copercini)](https://github.com/copercini/), who has some great examples in their [esp8266-aws_iot](https://github.com/copercini/esp8266-aws_iot) repository.

While this post was written in the context of connecting to AWS IoT Core, the methods of transforming and loading certificates to a WiFi Client connection should hold up for other uses. This walkthrough was done on MacOS- I've run into issues attempting this on a Windows machine running WSL (Windows Subsystem for Linux), and I'll note where that comes up when we get to it.

## Materials
* IDE: I currently use [PlatformIO](https://platformio.org/), but this is also doable with the Arduino IDE using the [arduino-esp8266fs-plugin](https://github.com/esp8266/arduino-esp8266fs-plugin).
* Keys and Certs: These are generated whenever a new **Thing** is registered to AWS IoT, or they can be directly generated in the console via **Secure** -> **Certificates**. Each certificate will need a policy attached to it to define which actions the device can take, a topic that deserves a post of its own.
    * Private Key (*random-string*-private.pem.key)
    * Certificate (*random-string*-.certificate.pem.crt)
* Certificate Authority Cert: You'll also need to download a copy of the [Amazon Root CA](https://www.amazontrust.com/repository/AmazonRootCA1.pem) certificate.

## Walkthrough
### 1. DER Encrypt the Certificates
The ESP8266's security libraries don't like the keys and certs in their native format, but they do like binary DER encoded certificates. Fortunately, this is a simple process using the `openssl` tool.

The Certificate Authority and Certificate are both converted using the `x509` subcommand, and the command is written to change the file name to something more generic so the certificate loading code  can be re-used more easily.

```
openssl x509 -in AmazonRootCA1.pem -out ca.der -outform DER \
openssl x509 -in **random-string**-certificate.pem.crt -out cert.der -outform DER
```

The Private Key encryption uses the `rsa` subcommand, but also generecizes the key name for re-use later.

```
openssl rsa -in 689fc33bb1-private.pem.key -out private.der -outform DER
```

### 2. Upload Certs to Flash Memory (SPIFFS) via PlatformIO
Note: I have not been able to get this working on a Windows machine with WSL (Windows Subsystem for Linux). I’ve only been able to upload files on OS X, although I suspect a dedicated Linux machine would also work. Maybe this is a FAT vs. NTFS issue? If you’ve figured out how to do it, please let me know!

Platform.io makes uploading data to the onboard flash memory ([SPIFFS](https://arduino-esp8266.readthedocs.io/en/latest/filesystem.html#spiffs-and-littlefs)) simple.

1. Create a new folder at the project root named `data`.

{% asset_img upload-new-data-dir.png "Folder named data at the project root"%}

2. Add the DER encrypted files to the new `/data` directory.

{% asset_img upload-move-encrypted-files.png "DER encrypted files within the data directory"%}

3. Click ‘Run Task’ (checklist icon).

{% asset_img upload-run-task-icon.png "PlatformIOs run-task shortcut"%}

4. In the command palette, search for ‘Upload file system image’ and click it to execute the task.

{% asset_img upload-upload-command-palette.png "Upload file system image command in the PlatformIO command palette"%}

5. The terminal will log output as the upload progresses, and should end with a success.

Now that the certificates are loaded into the device’s flash memory, we need to add them to the WiFi client.

### 3. Load the Certificates
I can't take credit for the code that loads the certificates! The example I used to get started is from [copercini/esp8266-aws_iot](https://github.com/copercini/esp8266-aws_iot/blob/master/examples/mqtt_x509_DER/mqtt_x509_DER.ino).

I'm reposting edited portions of their example code. If you'd like something you can copy/paste, grab it from their repository- they deserve the credit.

First, the libraries that we need to use:
```
#include "FS.h"             // File system commands to access files stored on flash memory
#include <ESP8266WiFi.h>    // WiFi Client to connect to the internet
#include <PubSubClient.h>   // MQTT Client to connect to AWS IoT Core
#include <NTPClient.h>      // Network Time Protocol Client, used to validate certificates
#include <WiFiUdp.h>        // UDP to communicate with the NTP server
```

These should get moved out to a `secrets.h` file that is in `.gitignore`, to avoid putting credentials in version control.
```
const char* ssid = "Wifi_ssid";
const char* password = "Wifi_password";
const char* AWS_endpoint = "aaaaaaaaaaaaaa.iot.us-west-2.amazonaws.com";
```

Then, establish clients to talk to the NTP server to get the current time
```
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");
```

Declare a function that will be called whenever the device receives a message- in this case, it prints the topic and message contents to Serial.
```
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();
}
```

Declare a WiFi client and pass it to a PubSub client that will connect to AWS.
```
WiFiClientSecure espClient;
PubSubClient client(AWS_endpoint, 8883, callback, espClient); 
```

The setup_wifi() function is pretty standard until the end, where the espClient time is set to the NTP time. This is necessary for certificate decryption.
```
void setup_wifi() {
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  timeClient.begin();
  while(!timeClient.update()) {
    timeClient.forceUpdate();
  }

  espClient.setX509Time(timeClient.getEpochTime());
}
```

The reconnect function is called whenever the MQTT connection drops. It attempts to reconnect- if successful, it publishes a message. If not, an error message is logged to `Serial`.
```
void reconnect() {

  // Loop until the client connects
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");

    // Attempt to connect
    if (client.connect("ESPthing")) {
      Serial.println("connected");

      // Once connected, publish an announcement.
      client.publish("outTopic", "hello world");

      // Resubscribe to the inbound topic.
      client.subscribe("inTopic");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");

      char buf[256];
      espClient.getLastSSLError(buf,256);
      Serial.print("WiFiClientSecure SSL error: ");
      Serial.println(buf);

      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
```

First bit of the setup function is straightforward- initialize `Serial` and set up the wifi connection.
```
void setup() {
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  setup_wifi();
  
  // TPH: I've played around with this and I don't think it's necessary.
  delay(1000);
```

Now the cert loading starts. In my code I actually moved this into the `setup_wifi` function, since that function handles similar operations such as setting the X509 time on the client connection. It could probably be simplified further.
```
  // Attempt to mount the file system
  if (!SPIFFS.begin()) {
    Serial.println("Failed to mount file system");
    return;
  }
```

The files each need to be loaded to memory from the file system and then loaded to the client connection. This pattern gets repeated 3 times- for the cert, the private key, and then the certificate authority. There is a delay between the three operations that I've been able to reduce without affecting performance.
```
  // Load certificate file from file system
  File cert = SPIFFS.open("/cert.der", "r");
  if (!cert) {
    Serial.println("Failed to open certificate from file system");
  }
  else {
    Serial.println("Successfully opened certificate file");
  )

  delay(1000);

  // Load certificate to client connection
  if (espClient.loadCertificate(cert)) {
    Serial.println("Certificate loaded to client connection");
  }
  else {
    Serial.println("Certificate not loaded to client connection");
  }

  // Load private key file from file system
  File private_key = SPIFFS.open("/private.der", "r");
  if (!private_key) {
    Serial.println("Failed to open private key from file system);
  }
  else {
    Serial.println("Successfully opened private key file");
  }

  delay(1000);

  // Load private key to client connection
  if (espClient.loadPrivateKey(private_key)) {
    Serial.println("Private key loaded to client connection");
  }
  else {
    Serial.println("Private key not loaded to client connection");
  }

  // Load CA file from file system
  File ca = SPIFFS.open("/ca.der", "r");
  if (!ca) {
    Serial.println("Failed to open CA from file system");
  }
  else {
    Serial.println("Successfully opened CA file");
  }

  delay(1000);

  if (espClient.loadCACert(ca)) {
    Serial.println("CA loaded to client connection");
  }
  else {
    Serial.println("CA not loaded to client connection");
  } 
}
```

The loop portion of the example reconnects to the internet if the connection drops, and periodically publishes a message to AWS IoT.
```
void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    ++value;
    snprintf (msg, 75, "hello world #%ld", value);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish("outTopic", msg);
  }
}
```

Using this pattern, it is possible to read DER encrypted certificates and keys into memory and add them to the AWS IoT client connection. If everything is configured properly (double check the device certificate policies!), the device should connect to AWS IoT and publish messages as well as log messages that it receives.

## 4. Build On!
The possibilities are endless once a connection to AWS IoT Core has been established. Using AWS IoT Rules Engine to filter and delegate messages, it is possible to trigger all sorts of events and functionalities within AWS. Your IoT project now has the power of the Cloud at it's disposal!

## Wrap Up
Are you building any cool IoT projects using AWS? I'd love to see them! Leave a comment below or [shout at me on Twitter](https://twitter.com/thomasphorton)!