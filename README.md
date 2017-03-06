# `viewer-sinatra`

This `viewer-sinatra` app dynamically generates the data pages of
the [EveryPolitician website](http://everypolitician.org).

It's a small Sinatra app that loads data on a per-request basis
using a `countries.json` file specified by the URL in the `DATASOURCE`
environment variable.

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

You can run `viewer-sinatra` using Vagrant (preferred way) or you can run it locally.

### Use Vagrant

First install Vagrant following [the steps in the official documentation](http://docs.vagrantup.com/v2/installation/). Then clone the project and start the Vagrant virtual box:

    git clone https://github.com/everypolitician/viewer-sinatra.git
    cd viewer-sinatra
    vagrant up
    vagrant ssh

Finally, follow the instructions displayed by the virtual machine.

**Note:** Changes to `app.rb` will require you to restart the webserver process.

Sass files are currently generated on each pageload, just like any other template. You do not need to manually compile the Sass.

### Run without Vagrant

You can also run this project locally without using Vagrant. First [install Foreman globally](https://github.com/ddollar/foreman#installation):

```bash
gem install foreman
```

Then clone the project and install the project's gems:

```bash
git clone https://github.com/everypolitician/viewer-sinatra.git
cd viewer-sinatra
bundle install
```

Finally, launch the site:

```bash
foreman start
```

It will be available at <http://localhost:5000/>

## Run the tests

To run the tests you have some options:

### Run just the page tests

```bash
bundle exec rake test:page
```

### Run just the web tests (slow)

```bash
bundle exec rake test:web
```

### Run just the extensions tests

```bash
bundle exec rake test:extensions
```

### Run absolutely all the tests (slow, as you guessed)

```bash
bundle exec rake test
```

### Run absolutely all the tests plus rubocop and bundle audit

```bash
bundle exec rake
```

## Sinatra, SASS, styling

The project uses [Sinatra](http://www.sinatrarb.com), an ultra-minimal Ruby MVC web app framework.

CSS styles are generated with [Sass](http://sass-lang.com).

We don’t use a pre-built CSS framework like Foundation or Bootstrap, but you can visit [localhost:5000/styling](http://localhost:5000/styling) once you have the project up and running, to see a live preview of the basic styles and components available to you.

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) guide for more information on
contributing to the project.

## Acknowledgements

Thanks to [Browserstack](https://www.browserstack.com/) who let us use their web-based cross-browser testing tools for this project.
