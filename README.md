# rocket-rides-reads [![Build Status](https://travis-ci.org/brandur/rocket-rides-reads.svg?branch=master)](https://travis-ci.org/brandur/rocket-rides-reads)

This is a project based on the original [Rocket Rides][rides] repository to
demonstrate what it might look like to implement reads from a replica that are
guaranteed to never be stale. See [the associated article][reads] for full
details.

## Setup

Requirements:

1. Postgres (`brew install postgres`)
2. Ruby (`brew install ruby`)
3. forego (`brew install forego`)

Install dependencies, create a database and schema, and start running the
processes:

```
bundle install
createdb rocket-rides-reads
psql rocket-rides-reads < schema.sql
forego start
```

## Development & testing

Install dependencies, create a test database and schema, and then run the test
suite:

```
bundle install
createdb rocket-rides-reads-test
psql rocket-rides-reads-test < schema.sql
bundle exec rspec spec/
```

[reads]: https://brandur.org/postgres-reads
[rides]: https://github.com/stripe/stripe-connect-rocketrides

<!--
# vim: set tw=79:
-->
