---
title: Replicating the Travis Build Matrix with Docker
date: 2019-06-03
---

It's beneficial to test your open-source software library works correctly with
multiple versions of its dependencies, and multiple versions of the programming
language. You want to have confidence the library works as intended for your
users, and prevent regressions.

In the Ruby world there are great tools - like [Appraisal] - which ease the
process of testing against various versions of dependencies.

[Appraisal]: https://github.com/thoughtbot/appraisal

Continuous integration services can support testing multiple language versions:

- Workflows on CircleCI 2.0 can use a job-per-version
- Travis has a [build matrix] feature to combine different language and
  environment configurations

[build matrix]: https://docs.travis-ci.com/user/build-matrix/

But what if you want to test multiple configurations, dependencies and language
versions locally? Or debug a failure in a specific combination without having to
push and wait for CI?

With these goals in mind I've created [dmatrix]. It allows you to define a
matrix of Docker `build-arg` and `env` variables:

[dmatrix]: https://github.com/odlp/dmatrix

```yaml
matrix:
  build_arg:
    FROM_IMAGE:
      - ruby:2.4-alpine
      - ruby:2.5-alpine
      - ruby:2.6-alpine
    BUNDLE_GEMFILE:
      - gemfiles/factory_bot_4_8.gemfile
      - gemfiles/factory_bot_5.gemfile
```

Each possible combination will then be built and run in parallel:

```
bundle exec dmatrix -- <your command>
```

Dmatrix is written in Ruby, but you can use it to test projects written in any
language if you have Ruby & Docker available locally.
