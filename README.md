# Sorin

Sorin is an extensible discovery and research platform produced by St. Edward's University's Munday Library. Sorin fills in the gaps between existing library systems by providing a clean, simple, and integrated web interface for searching catalogs, databases, or other endpoints, creating collections of search results, collaboratively adding notes and file attachments, exporting to other platforms, and sharing your work with the rest of the community or the open web.

Sorin's core is a simple, fast, stable, and scalable Elixir data processing layer currently configured to use PostgreSQL for data storage, Google OAuth for authentication, and Amazon's S3 for file storage. Phoenix, React, and Redux are used to provide a kanban-like user interface over the web.

This repo's initial commit is the culmination of two years of effort distributed among [three developers and a team of strategists, advisers, supporters, and testers](AUTHORS.md).

## Project Status

Sorin is in active development, and though it has been in production use at St. Edward's University since October 2018, it should still be considered experimental. All core functionality is in place, stable, and performant, but there is more work to do, including the implementation of a REST API, improving documentation, generalizing the user account provisioning and authentication systems, and, in general, refactoring the code to make it simpler and more idiomatic. Pull requests are welcome.

## Basic Workflow

[![IMAGE OF SORIN VIDEO](https://img.youtube.com/vi/aVIIiqC5JXU/maxresdefault.jpg)](https://youtu.be/aVIIiqC5JXU)

[Introductory video](https://youtu.be/aVIIiqC5JXU)

Sorin is a single-page application that presents users with tabs to access two interfaces: **Search**, and **Collections**.

The **Search** interface has a simple search bar that can be customised with Sorin *extensions* to search any catalog or service with an API, with optional filtering, such as by title or subject. Search results offer traditional search/browse affordances, including citation generation, catalog description fields, and access to the resource itself, either directly or at the originating catalog (access details and functionality will vary according to the catalog being queried, and is customizable). Sorin's key new feature is a button labeled *Save it!*, which saves the resource to a collection under **Collections** called "Inbox."

In the **Collections** interface, users will find one default collection--the "Inbox" that all resources saved from **Search** end up in. Users can make any number of additional custom collections, and the collections can be entitled, tagged, color coded, and rearranged according to preference.

Formatted notes, file attachments, and tags can be added to both resources and whole collections. Citations can be accessed for individual resources, or for all of the resources in a given collection. 

Collections can be **published**, which makes them findable from the search bar in the **Search** interface. A collection found in search results can be **cloned**, which adds an always up-to-date but read-only view of it to a user's Collections; collections can also be **imported**, which creates an entirely new, identical copy of it that can be edited, but to which an indelible statement of provenance has been added. Collections can be shared with other users and exported to Google Docs.

## Features

* Catalog search
* Search other users' published collections
* Clone or import other users' published collections
* Share read-only views of collections at unique URLs, even outside the community (file attachments are not accessible at this view)
* Formatted notes of arbitrary length on resources and collections
* File attachments that get saved to Amazon S3, with a configurable disk quota for users (file attachments only available to authenticated users)
* Extension architecture for adding new search targets or other features
  * Worldcat provided by default; Ex Libris Primo also available
* Themable via the [SorinTheme extension](https://github.com/seulibrary/Sorin-Theme)
* **Massively** concurrent, fault-tolerant, and scalable - runs on the battle-tested [Erlang/OTP](https://en.wikipedia.org/wiki/Erlang_(programming_language)) virtual machine

## Planned Features

The following features are on the roadmap:

* Co-authorship of collections, where arbitrary numbers of users can own and edit a collection together
* A REST API
* Collection *archiving*, keeping the collection available but not visible in **Collections**
* Collection *grouping*, to ease the management of large numbers of collections
* Integration, via extensions, with a growing ecosystem of external services, including search catalogs, collection export targets, and academic support platforms such as Canvas
* Previews of embedded content (e.g., images and videos in note fields)
* PDF reading and annotating
* Improvements to the theming capabilities of the [SorinTheme extension](https://github.com/seulibrary/Sorin-Theme)

...and there are usually many other more exotic ideas in some stage of precipitation :smile:

## About the Technology

Sorin is fundamentally a [Phoenix](https://phoenixframework.org/) application that uses PostgreSQL for data storage, Google OAuth for user authentication, S3 for file storage, and React and Redux to provide an out-of-the-box web interface. Sorin uses API calls to query search targets, and provides an extension architecture for adding your own new search targets. A [Worldcat Search API](https://www.oclc.org/developer/develop/web-services/worldcat-search-api.en.html) extension is provided out of the box, though to use it, you will need to provide your own Worldcat [wskey](https://www.oclc.org/developer/develop/authentication/how-to-request-a-wskey.en.html).

## How to Get, Build, and Run Sorin

Sorin depends on recent versions of Erlang/OTP, Elixir, Phoenix, Node.js, and PostgreSQL. For installation of this stack, we recommend following the [Phoenix installation guide](https://hexdocs.pm/phoenix/installation.html). For more information about installing, configuring, and compiling Sorin, please see [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md).

## Versioning

As recommended by and for the rest of the Elixir community, we tag production-ready releases with [Semantic Versioning](http://semver.org/). To see the list of versioned releases, please see the tags on this repository.

## Questions, Feedback, and How to Get Involved

We welcome questions, ideas, feedback, comments, and bug reports via the Sorin issue tracker. To contribute bug fixes, improvements to documentation, or new features, pull requests are gratefully encouraged. We would also be delighted to work with you on the development of new extensions, especially for new search targets. For more information please see [CONTRIBUTING.md](CONTRIBUTING.md). Please note that this project is released with a [Contributor Code of Conduct](code-of-conduct.md). By participating in this project you agree to abide by its terms.

## License

This project is licensed under the GNU General Public License v3.0 -- see [LICENSE](LICENSE) for details.

## Documentation

* [AUTHORS.md](AUTHORS.md) - The complete list of all of Sorin's contributors and collaborators. If you submit a patch or pull request, make sure to include yourself!
* [CHANGELOG.md](CHANGELOG.md) - A complete human-readable history of changes to Sorin
* [code-of-conduct.md](code-of-conduct.md) - A local copy of the [Contributor Covenant](https://www.contributor-covenant.org/), which codifies our commitment to value people as whole human beings and to foster an atmosphere of kindness, cooperation, and understanding throughout our community
* [CONTRIBUTING.md](CONTRIBUTING.md) - Guidelines and suggestions for how to get involved in the community and help us improve Sorin
* [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md) - Technical documentation for Sorin developers, installers, maintainers, and system administrators
* [LICENSE](LICENSE) - A local copy of the GNU General Public License v3.0, under which Sorin is licensed
* README.md - This file, which introduces Sorin at a high level.
