---
title: Deploying a Static Website on AWS
date: 2018-03-08 19:40:55
tags:
---

Let's start off with a hypothetical- you've got a simple static website for a small project, and you want to host it online. What's the best way? You can score different methods on a variety of categories:

* Cost
* Scalability
* Simplicity

For the majority of use cases, the best way to do this is going to be to use Amazon S3 to host your content. Why?

## Simplicity
As I'll show you, deploying a static website via S3 is as easy as can be.

## Cost of Hosting
https://aws.amazon.com/getting-started/projects/host-static-website/
https://aws.amazon.com/free/

## Scalability
Before jumping in- I want to clarify what I mean when I say a static website. A static website is a collection of HTML files and whatever resources you need to make it pretty or to add functionality. A basic static website directory looks something like this:

```
- css/
  |- styles.css
- js/
  |- scripts.js
- index.html
- error.html
```

Amazon S3 makes hosting something like this dead simple. [Create an S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html) using the default settings. Once created, go to the 'Properties' tab for the bucket, and click 'Static Website Hosting'. Select the 'Use this bucket to host a website' radio button, and declare and index and error document, which should match up with your site structure.

{% asset_img s3-static-website-options.png [S3 Static Website Options]}

Your site will now be accessible at the 'Endpoint' shown on the options page, and should look like `<bucket-name>.s3-website-<region>.amazonaws.com`. If you click the link, you'll see something like this:

{% asset_img s3-static-website-error.png [403 Forbidden Error]}

What happened here? If you created a new bucket and followed what I've told you so far, you don't have an `index.html` in your bucket, causing an error- and on top of that, you don't have an `error.html`!

Let's go ahead and create some simple examples now- make an `index.html` and `error.html` in your text editor, with the following contents:

**index.html**
```
<h1>Hello World</h1>
```

**error.html**
```
<h1>Error!</h1>
```

Back in your browser, upload both files to your S3 bucket.

{% asset_img s3-static-website-upload.png [Uploading files to an S3 Bucket]}

Once that's complete, you can try visiting your website again. You should still see the 403 error. This is because by default, all objects in S3 are not world-readable. You've got two options at this point- either explicitly make each file public, or grant access for the entire bucket. Since we're only going to put files for a public website in this bucket, it's safe to mark all of the files public. Be careful of what you're doing if making changes to an existing bucket!

{% asset_img s3-static-website-make-public.png [Making an S3 Bucket Public]}

Now if you go back to the bucket URL, you should see your Hello World.
