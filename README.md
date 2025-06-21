# ⚓ Anchor Migrations
Anchor Migrations are SQL migrations with various restrictions, intended to be applied before ORM migrations, for a couple of specific use cases.

Anchor migrations support a restricted set of DDL operations by design. They must be additive, not destructive, and they must be idempotent, meaning they can be applied repeatedly but are applied exactly once when they don’t already exist. 

## Commands
```sh
anchor init         # initialize directories
anchor generate     # generate an empty versioned .sql file, to be filled in
anchor lint         # safety-lint all .sql files using Squawk
anchor backfill     # Backfill a Rails migration from the SQL
anchor migrate      # Run the Anchor Migration DDL
```

## Installation
Add `anchor_migrations` to your `development` group Gemfile
```rb
group :development do
  gem 'anchor_migrations'
end
```
Then run `bundle install`.

## Preconditions
Anchor Migrations is very restricted now and expects a few things:
- `DATABASE_URL` environment variable to be set
- `psql` client to be reachable, it's used to apply SQL DDL
- [Squawk](https://squawkhq.com) to be reachable and ready to use

## Safety linting
Squawk can be used as a linter on SQL migrations, to check for unsafe operations. For example, creating an index without using CONCURRENTLY. Squawk catches this. The developer should install Squash and use the “lint” command when preparing their SQL DDL.

Anchor Migrations are applied using a psql client connection. By default a 2 second `lock_timeout`[^docs] is set.

## What problems do Anchor migrations solve?
1. Anchor Migrations are an additional release process for organizations that release their code and ORM migrations infrequently. Anchor migrations add another option.
1. Anchor Migrations can be used for purposefully out-of-band migrations, like adding indexes concurrently on huge tables, that aren’t ideal to perform using the traditional ORM migrations release process.

Anchor Migrations aren’t meant to replace ORM migrations, but to help fill in a couple of gaps to keep an organization moving. Despite the additional velocity, the SQL DDL can still be checked for safety. Because Anchor Migrations generates an ORM migration, there’s no loss of fidelity in the normal process. 

## Preparing a PR
For a PR, prepare:
1. The Anchor Migration SQL file that’s been linted. Don’t apply it yet until it’s been reviewed.
1. The backfilled, generated Rails Migration. Run “db:migrate” like normal to apply it. The developer submits the migration file and the diff to either db/structure.sql or db/schema.rb like they normally would.

Once the PR is approved, the developer can run `anchor migrate` to apply the DDL.

## Why Use Anchor Migrations?
### Structural dependencies
Structural elements like tables or columns, that must be in place before code is released that depends on it, where it might be more convenient or helpful to perform these out of band, while still keeping all databases in sync.

### Query support, data integrity, data quality
Indexes and constraints that support query performance or data integrity and data quality, that code doesn't depend on, but improve the system. Sometimes we want to apply new indexes as soon as we know they’re useful and needed to improve performance.

### Long running DDL changes
On large tables, creating indexes concurrently can take a long time. It's nice to perform that during a low activity period, which is often not at the same time as code releases.

## Anchor Migrations Properties
### Idempotent
Anchor migrations in SQL must be written using idempotent operations. This allows the SQL to be the backfill source for an Active Record migration which is then idempotent as well.

### Restriced DDL: What DDL is supported for Anchor Migrations?
Only additive, non-destructive, non-blocking, idempotent DDL is supported. This list is restricted heavily now although additional DDL types can be added in the future
1. `CREATE INDEX IF NOT EXISTS`

### What’s out of scope for Anchor Migrations?
Anchor Migrations are only additive, not destructive. They should not be used for:
1. `DROP TABLE`
1. `ALTER TABLE ALTER COLUMN`
1. Adding non-nullable column, or a column with a default value
1. Dropping constraints
1. Adding initially valid constraints
1. Add indexes without using concurrently

[^docs]: <https://www.postgresql.org/docs/current/runtime-config-client.html>

## Building
```sh
gem build anchor_migrations.gemspec
gem install ./anchor_migrations-0.1.0.gem
```

## Testing
```sh
anchor help
```
