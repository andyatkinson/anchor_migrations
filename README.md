# ⚓ Anchor Migrations
Anchor Migrations are additive, safety-linted, hand-authored, idempotent SQL DDL migrations.

They are the migration files, and anchor migrations are a "process" that complement ORM migrations.

The "anchor" part means DDL changes to a database schema design, that are intended to *anchor* code that depends on them or support queries.

Anchor Migrations complement ORM migrations. Currently Rails (Active Record) migrations can be generated from anchor migrations. Anchor migrations versioning is inspired by Active Record.

## What problems do Anchor migrations solve?
1. An infrequent software release process limits how quickly DDL changes can be applied. Anchor migrations adds another option.
1. Some DDL changes like adding indexes on huge tables, takes a long time. Anchor migrations are a way to separate that from software releases.

What types of DDL changes are a good fit for anchor migrations?
### Structural dependencies
Structural elements like tables or columns, that must be in place before code is released that depends on it.

### Query support, data integrity, data quality
Indexes and constraints that support query performance or data integrity and data quality, that code doesn't depend on, but improve the system

### Long running DDL changes
On large tables, creating indexes concurrently can take a long time. It's nice to perform that during a low activity period, which is often not at the same time as code releases.

## Anchor Migrations Properties
### Idempotent
Anchor migrations in SQL must be written using idempotent operations. This allows the SQL to be the backfill source for an Active Record migration which is then idempotent as well.

### Restrictions: What DDL is supported for Anchor Migrations?
Only additive, non-destructive, non-blocking, idempotent DDL is supported:
- Create table if not exists
- Add nullable column if not exists
- Create indexes concurrently if not exists
- Add check constraint if not exists, initially not valid

### What it doesn't do
Anchor Migrations are only additive, not destructive. Cannot:
- Drop tables
- Drop columns
- Add non-nullable columns
- Drop constraints
- Add initially valid constraints
- Add indexes non-concurrently

## Usage
Prerequisite: Depends on Squawk for safety-linting PostgreSQL SQL DDL.
Install Squawk: <https://squawkhq.com/docs>

Add `anchor_migrations` to your `development` group Gemfile
```sh
bundle install
```

Now you can run:
```sh
anchor init
anchor generate # generates a versioned .sql file
anchor lint     # safety-lints all .sql files in directory (using Squawk), marks file unsafe or safe
anchor migrate  # PENDING
```

## Rails integration
Ruby on Rails creates this table and stores a single version in it per migration:
- `schema_migrations`

TBD:
Anchor migrations adds a similar table:
- `anchor_migrations`
- `version` `not null` (same version as the Rails migration)

And a couple more fields:
- `linted_at` `timestamptz` nullable
- `applied_at` `timestamptz`
