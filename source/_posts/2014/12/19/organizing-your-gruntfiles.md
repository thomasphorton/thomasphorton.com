---
title: Gruntfile Organization with Modules
date: 2015-11-06 19:40:55
---

*based on [More Maintainable Gruntfiles](/http://www.thomasboyt.com/2013/09/01/maintainable-grunt.html) by Thomas Boyt*

[Grunt.js](https://gruntjs.com/) has been dubbed ‘The Simple Task Runner’. So why is the task configuration anything but simple? There’s a solution for that.

<!-- more -->

In my experience, Gruntfiles can quickly become a mess. I believe that by splitting your Grunt task configurations out into modules, you can keep a handle on things much easier. By modularizing everything, it also makes it easy to re-use common tasks between projects. You might even be able to configure a common task runner that each new project inherits from.

I’ve created a Grunt tutorial repository for [Modular Gruntfiles](https://github.com/thomasphorton/grunt-start/)– I’d suggest cloning it and playing along. Once you’ve got the hang of it, try tailoring it to suit your needs in your next project!

It’s not an exaggeration to say that [More Maintainable Gruntfiles](/http://www.thomasboyt.com/2013/09/01/maintainable-grunt.html) changed my development life. Knowing what I know now, it’s relatively simple to reason through what is going on in a standard Gruntfile- one huge JSON blob is being passed to the Grunt config and you’re in action. Monolithic objects are intimidating though, especially since Grunt configurations can nest as deep as 3-4 levels on standard tasks. Separating the task configurations out into discrete files makes it easy to concentrate on the task at hand- figuratively and literally.

## Gruntfile Modules
An example option module looks like this (jshint.js)

```
module.exports = {
  scripts: {
    src: [
      ’src/js/*'
    ]
  }
};
```

6 lines? Much easier than scrolling through a 100+ line Gruntfile. It’s simple, and it makes sense. Now there’s a 1:1 map between each of your Grunt tasks and the configuration options.

## Loading the Modules
Now for the magic- we need to read each of these files into the Grunt initConfig. I’ve cleaned up Thomas Boyt’s function a little bit, but the bones were good.

```
// Load task options from a given path
function loadConfig(path) {
  var glob = require(‘glob’);
  var obj = {};

  // For each file in the given path
  glob.sync('*', { cwd: path }).forEach(function(option) {

    // Remove .js from the filename to get the Grunt task name
    var key = option.replace(/.js$/, '’);

    // Assign the option module to the objects
    obj[key] = require(path + option);
  });

  return obj;
}
```

Simple- glob the given path, and give each file’s export a spot in a new object. Now we’ve got a data structure similar to the config object in a traditional Gruntfile.

Next, extend that object into the final config object, and sprinkle in any additional configuration options you find necessary.

```
grunt.util._.extend(config, loadConfig('./tasks/options/'));
```

There you go! Now you’ve got a modularized workflow. Next time, I’ll show you how we go about registering Tasks.

Want to dive deeper into Grunt.js? Pick up [Getting Started with Grunt: The JavaScript Task Runner](http://amzn.to/1lNQhfN) by Jaime Pillora.