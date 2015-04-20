# Install

Local development requires [Vagrant](http://docs.vagrantup.com/v2/installation/).

    git clone https://github.com/mysociety/popolo-viewer-sinatra.git
    cd popolo-viewer-sinatra
    vagrant up
    vagrant ssh

Then follow the instructions displayed by the virtual machine.

**Note:** Changes to `app.rb` will require you to restart the webserver process.

Sass files are currently generated on each pageload, just like any other template. You do not need to manually compile the Sass.

# Contributing

The project uses [Sinatra](http://www.sinatrarb.com), an ultra-minimal Ruby MVC web app framework.

CSS styles are generated with [Sass](http://sass-lang.com).

We don’t use a pre-built CSS framework like Foundation or Bootstrap, but you can visit [localhost:5000/styling](http://localhost:5000/styling) once you have the project up and running, to see a live preview of the basic styles and components available to you.
