# `viewer-sinatra`

This `viewer-sinatra` app dynamically generates the data pages of
the [EveryPolitician website](http://everypolitician.org).

It's a small Sinatra app that loads data on a per-request basis
using a `countries.json` file specified by the URL in the `DATASOURCE` file.

Typically, we use this with `DATASOURCE` pointing at a specific version
(often the *most recent version*) of `countries.json`, which is the
machine-readable index file for the EveryPolitician data, which itself
contains URLs for all the data files.

For example, `DATASOURCE` may be something like:

<code>https://cdn.rawgit.com/everypolitician/everypolitician-data/<em>sha1-hash</em>/countries.json</code>

Since `countries.json` and the URLs it contains are all versioned, that is,
linked to a specific commit, then `viewer-sinatra` will generate web pages populated
with data specific to the time of that commit.

We use it to [generate the (static) HTML pages for the live site](https://medium.com/@everypolitician/how-i-build-the-everypolitician-website-6fd581867d10)
as well as [spinning up previews for data that hasn't been merged yet](https://medium.com/@everypolitician/i-let-humans-peek-into-the-future-f4fe09eba59c)
on Heroku.

This is a lightweight app for generating the site. It is **not for use in production**.

See [everypolitician/everypolitician](https://github.com/everypolitician/everypolitician) for issues
and a jumping-off point to more repos in the EveryPolitician stable (for example, `viewer-sinatra` itself commits
its output to [`viewer-static`](https://github.com/everypolitician/viewer-static)
when building the live site).



## Install

Local development requires [Vagrant](http://docs.vagrantup.com/v2/installation/).

    git clone https://github.com/everypolitician/viewer-sinatra.git
    cd viewer-sinatra
    vagrant up
    vagrant ssh

Then follow the instructions displayed by the virtual machine.

**Note:** Changes to `app.rb` will require you to restart the webserver process.

Sass files are currently generated on each pageload, just like any other template. You do not need to manually compile the Sass.

## Sinatra, SASS, styling

The project uses [Sinatra](http://www.sinatrarb.com), an ultra-minimal Ruby MVC web app framework.

CSS styles are generated with [Sass](http://sass-lang.com).

We don’t use a pre-built CSS framework like Foundation or Bootstrap, but you can visit [localhost:5000/styling](http://localhost:5000/styling) once you have the project up and running, to see a live preview of the basic styles and components available to you.

## Acknowledgements

Thanks to [Browserstack](https://www.browserstack.com/) who let us use their web-based cross-browser testing tools for this project.
