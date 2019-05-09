# Core

This application encodes Sorin's data model, and provides Elixir functions for data processing.

* `config/` holds the configuration files for interfacing with a PostgreSQL database.
* `lib/` holds, for each fundamental Sorin data type (e.g., collections, resources, users, etc), one Elixir file encoding the type as a Phoenix schema, and one Elixir file encoding various helper functions for CRUD operations and other transformations for that data type.
  * `lib/collections/` also holds a Phoenix schema for `CollectionsUsers`, which is used as a database join table, but for which no helper functions are provided.
  * `lib/mix/tasks/` holds functions used by Mix to manage Sorin extensions.
* `priv/repo/` holds data and scripts used to populate Sorin's databases.
  * `priv/repo/migrations/` holds Sorin's database schemas
  * `priv/repo/seeds.exs` is a script that populates Sorin's database with temporary, example database records, for testing purposes
  * `priv/repo/assets/` holds dummy files used by `seeds.exs` to test file attachments.
