# ⚓ Anchor Migrations
Anchor Migrations are SQL DDL, non-blocking, idempotent, and augment the normal ORM migrations process.

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
Anchor Migrations are restricted and opinionated for now, expecting a few things:
- Postgres only, 13+
- `DATABASE_URL` environment variable is set to the database to migrate (e.g. production), and is reachable, in order to apply migrations
- The `psql` client can be reached by the gem
- The [Squawk](https://squawkhq.com) executable is installed and reachable for use

## Safety linting and lock_timeout
Squawk is used on SQL migrations to check for unsafe operations. For example, creating an index or dropping an index without using CONCURRENTLY is detected by Squak. Anchor Migrations will require safety-linted SQL, although right now it’s up to the developer to run `anchor lint` in their workflow.

When Anchor Migration SQL is ready to apply, a psql client connection is used for that. By default a 2 second `lock_timeout`[^docs] is set.

## What problems do Anchor migrations solve?
1. Anchor Migrations are an additional mechanism to release safe DDL changes that don’t have code dependencies, while keeping all databases in sync using ORM migrations.

Anchor Migrations are a process for organizations not using [Trunk Based Development](https://trunkbaseddevelopment.com) (TBD) or infrequent releases, to allow safe DDL to get released more regularly.

Because Anchor Migrations generate the ORM (Active Record) migration *from* the SQL, there’s no loss of fidelity in the normal ORM migration process. 

## Preparing a PR
For a PR, prepare:
1. The Anchor Migration SQL file. This was linted by the developer using Squawk and iterated on until it was safe.
1. The backfilled, generated Rails Migration. Run “db:migrate” like normal to apply it. The developer submits the migration file and the diff to db/structure.sql or db/schema.rb like they normally would.

Once the PR is approved containing these files, the developer can run `anchor migrate` to apply the DDL. The applied migration can be recorded, and the PR merged. The idempotent Rails migration applies anywhere in lower environments, and does not apply when it reaches production, where the Anchor Migration already applied the equivalent SQL DDL.

## Why Use Anchor Migrations?
### Query support, data integrity, data quality
Indexes (and eventually constraints) that support query performance or data integrity, but has no code dependencies. These improve performance and data quality, and arguably shouldn’t be “blocked” by ORM migrations being released.

### Long running DDL changes
On large tables, creating indexes concurrently can take a long time. It's nice to perform that during a low activity period, which is often not at the same time as code releases.

## Anchor Migrations Properties
### Idempotent
Anchor migrations in SQL must be written using idempotent operations. This allows the SQL to be the backfill source for an Active Record migration which is then idempotent.

### Restricted DDL: What DDL is supported for Anchor Migrations?
Only non-blocking, idempotent DDL is supported. This list is restricted heavily now although additional DDL types can be added in the future
1. `CREATE INDEX CONCURRENTLY IF NOT EXISTS`
1. `DROP INDEX CONCURRENTLY IF EXISTS` (Postgres 13+)

Roadmap:
1. `ALTER TABLE ALTER COLUMN IF NOT EXISTS` (only `NULL` values)
1. Add check constraint, initially not valid

### What’s out of scope for Anchor Migrations?
Anchor Migrations are non-blocking and idempotent.

For destructive operations, Anchor Migrations should be limited to DDL that no application
code depends on. That's because application code references need to be removed first.

They should not be used for:
1. `DROP TABLE`
1. Adding non-nullable column, or a column with a default value
1. Dropping constraints
1. Adding initially valid constraints
1. Add indexes without using concurrently

[^docs]: <https://www.postgresql.org/docs/current/runtime-config-client.html>

## Building
```sh
gem build anchor_migrations.gemspec
gem install ./anchor_migrations-0.1.0.gem
anchor help
```

## Testing in Rails
```sh
bundle exec anchor help
```
