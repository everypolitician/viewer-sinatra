## Architecture

There are a gazillion approaches to how to architect a webapp. They
often, rather annoyingly, appear to share terminology, but actually turn
out to use it very differently. (Or, worse, use terms in ways that are
subtly, but crucially, different.)

Here’s how _this_ app works:

As with the rest of the EveryPolitician project our development
practices aim to maximise simplicity and maintainability.

Here we hope to achieve that by using a lightweight framework, and
keeping a strict separation of concerns between the various parts of the
system.

The Sinatra app is largely controlled from and described by `app.rb`,
largely through a series of *routes*. These routes should themselves
have almost no logic — their only job is to instantiate a relevant
`Page` object, and then turn that into output, usually by passing it to
a Template.

The Page objects themselves should be entirely unaware of the outside
world in either direction:

1. They should know nothing about the environment from which they’ve
been called. This means that not only should they should have no
awareness of HTTP, query variables, etc, but equally importantly they
should know nothing about Sinatra either. If we ever switch to a
different framework, these classes should not need to change.

2. Similarly, they should know nothing about the Template engine that
they will be passed to. Switching between ERB and HAML, for example,
should not require any changes the Page classes. The one concession we
make here is that we assume that any templating system we use will have
the ability to call methods on objects.

Because of the way in which the app is actually used in production
(although this is a fully dynamic app, we serve an entirely static
version of the site, re-spidered from the app every time the underlying
data changes), we do not need some of the more complex behaviour that
has driven the evolution of most modern web frameworks. We expect our
approach to evolve over time, but we try to resist the lure of adding
complexity, abstraction, or indirection until we actually have a need
for it — and usually only as a result of refactoring it out of behaviour
we have already implemented, rather than because we think we _will_ need
it in future.

## Pull Requests

* Pull Requests (PRs) should be as minimal as possible. This lets us
deliver value as quickly as possible by reducing review time (complexity
generally increases non-linearly with size), and minimising unnecessary
coupling (if you can imagine one piece of your PR going
live independently of another part, then it should probably be a
separate PR, rather than them blocking on each other.)

* PRs should strictly separate refactoring from adding new functionality
(or fixing existing bugs). If you need to refactor an existing
implementation to more easily enable your change, you should split that
into a distinct PR (“make the change easy, then make the easy change”).

* PRs for refactoring should only ever change the code _or_ the tests,
never both simultaneously.

* PRs that add functionality should ensure not only that the tests pass,
but that at least one test is added that exposes that functionlity (i.e.
the test fails against `master`.)

## Style

### General

We automatically analyse all code using `rubocop`. Please ensure that
this passes before submitting a PR. We are always open to persuasion
that we should use different rules, and we are still in the process of
making all the code comply (in particular we have some classes that are
still too long and too complex), but our goal is to continue to tighten
these over time, so adding new exceptions to `.rubocop_todo.yaml` should
be treated as a last resort.

### Page classes

* The public methods define the data available to the Template engine.
Any method that is not expected to be called directly from a template
should be private.

* The `initialize` method should have no logic, other than to set
instance variables from named parameters.

* We maintain a very strong encapsulation — instance variables should
never be accessed directly, but always through (ideally private)
accessors. Slow calculations can be memoized (using the `@foo ||=
calculation` approach), but those variables should never be accessed
from outside the method in which they are stored.

### Templates

* Templates should never do any Hash lookups. Any time we need a
lightweight data structure, we make it a Struct instead.

## Testing

* All Page classes should have tests for all public methods. These
should live in `t/page/`, test that all methods return the expected
values, and run against known (and VCR-recorded) everypolitician data.

* Full integration tests that use rack to test HTTP input or HTML
output should be as minimal as possible, also run against a known
(recorded) dataset and live in `t/web/`.

* The integration test for live data is the ability to generate a static
site without error.

