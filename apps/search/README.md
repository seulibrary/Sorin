# Search

This application is the hub of Sorin's search-related functionality. 

`Search` is responsible for delegating search requests from clients to subqueries for (i) user collections held in the database, and (ii) the catalog extension specified in `sorin.exs` for catalog records; and for aggregating and returning the results to the client.

* `lib/search.ex` provides functions for searching collections by the 'fullname' of the collection's creator, searching collections by their content (title and tags), searching the catalog designated in `sorin.exs` via its extension application, and aggregating all of the above subqueries into a single master search.
  * `lib/search.ex` also offers a convenience function for testing and developing in IEx that provides a word randomly selected from `/usr/share/dict/words` to `Search.all()`
* `lib/collections.ex` provides the low-level database queries used by the collection search functions in `lib/search.ex`, and the functions for importing and cloning collections (which, yes, should probably be moved into `apps/core/lib/collections/`)
