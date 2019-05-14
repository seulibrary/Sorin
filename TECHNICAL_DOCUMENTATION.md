## Table of Contents

- [Hello, world!](#hello-world)
  - [Before we begin](#before-we-begin)
  - [Technical notes to be aware of](#technical-notes-to-be-aware-of)
  - [A high-level view of building and deploying](#a-high-level-view-of-building-and-deploying)
- [Local installation for development](#local-installation-for-development)
  - [External dependencies](#external-dependencies)
  - [Internal dependencies](#internal-dependencies)
- [Configuration and Customization](#configuration-and-customization)
- [Creating production releases](#creating-production-releases)
- [Deploying](#deploying)
- [Adding users](#adding-users)
- [Extensions](#extensions)
- [Appendix I - Setting up Google Auth](#appendix-i-setting-up-google-auth)
- [Appendix II - Introduction to S3](#appendix-ii-introduction-to-s3)
- [Appendix III - Theming with SorinTheme](#appendix-iii-theming-with-sorintheme)

## Hello, world!

One afternoon in the fall of 2016, St. Edward's University's Munday Library engaged in a thought experiment: if we were to model the library as an application, what would it do? After much lively discussion and debate and two years' worth of prototyping, developing, user testing, iterating, and reiterating, we discovered our question had grown along with us: if we build the right platform for collaborative work with the library, what will our community do with it? The results at St. Edward's have been thrilling, and we hope your community will enjoy it too -- and we hope you'll team up with us on future development.

Sorin is a web application written in [Elixir](https://elixir-lang.org/), with a front end written in [React.js](https://reactjs.org/). We chose React (and Redux) because we wanted an architecturally clean single page application framework that can handle state well. We chose Elixir for several reasons: we liked how simple it is to reason about, the high quality of its documentation and tooling, its concurrency model, and the fact that it runs on the [Erlang](https://www.erlang.org/) virtual machine, which has been highly regarded for decades for its incredible fault-tolerance and scalability.

### Before we begin

In order to keep the following documentation as concise and subject-specific as possible, we're going to make some assumptions. 

* **You will be using a Mac or Linux for development, and Linux for production.** Erlang, Elixir, Node, and PostgreSQL all run on *BSD and Windows, so those operating systems should work for Sorin, but we don't have documentation for that yet (pull requests welcome!).
* **You are comfortable working in a command line environment,** installing and configuring software on your development and production operating systems, and editing source code files in a suitable editor.
* **You are familiar with the basics of version control** -- you will need to fork and clone the Sorin repo, configure it for your environment, track your customizations in your own repo, and keep some configuration **out** of version control (e.g., Amazon S3 keys).
* **You will be running Sorin behind a reverse proxy, such as nginx or Apache.** This is a simple and widely-recommended setup for handling SSL that will provide all kinds of operational benefits. We will not explain how to install and configure nginx or Apache for your environment (yet -- documentation forthcoming), but will detail how to get Sorin set up for it.
* **Erlang, Elixir, and/or React are new to you.** It will occasionally be necessary to edit source code files or enter commands into Elixir's command interpreter, [IEx](https://hexdocs.pm/iex/IEx.html), but we will document these steps as completely as possible. With that said, if you decide to put Sorin into production, and especially if you decide to extend or adapt it, you'll probably want to do [some](https://elixir-lang.org/getting-started/introduction.html) [tutorials](https://hexdocs.pm/phoenix/overview.html). We found Elixir and React manageably simple to get up to speed with, and you probably will too.

### Technical notes to be aware of

* Though Erlang/Elixir/Phoenix applications [can be run directly from the directory they're installed to](https://hexdocs.pm/phoenix/deployment.html#starting-your-server-in-production), we will follow convention by recommending that you compile your application to a highly-optimized and self-contained Erlang *release*, which we will document below. As this documentation is being written Elixir 1.9 is being finished up, which adds native support for compiling releases. As soon as 1.9 is released, we will update this documentation for it; until then, Sorin will continue to use Elixir's [*Distillery*](https://github.com/bitwalker/distillery) library for this purpose, and detail its use below.
* Because (1) Sorin requires some site-specific configuration (e.g., adding your Amazon S3 keys), and (2) your instance will subsequently be compiled into a release, the documentation below assumes that you have:
  1. a *development* machine, probably your local laptop or desktop, where you will install all dependencies, make any changes you want or need to, and in general play and experiment;
  2. a *production* server that you will eventually run Sorin on for actual use in your community. The following documentation assumes that you will build your production releases on your production server itself, though you can also use a separate build/test machine of the same architecture and operating system as your production server.
* This documentation assumes that both while developing/testing and when running in production, Sorin and its PostgreSQL database will be running on the same server. Postgres can be moved to its own server, but that will not be documented here.
* Sorin is, in part, a search application; as such, it must have a target system it can search. This can in principle be anything with an API that returns json. To adopt a new search target, a *search target extension* must be created or installed [as described below](#extensions), but to facilitate experimentation, a search target extension for [WorldCat](https://www.worldcat.org/) is pre-installed.
* Sorin is in active development, and though it has been in production use by hundreds of users since October 2018 with no issues, data loss, or unplanned downtime, it should still be considered experimental.

### A high-level view of building and deploying

In high-level outline, building and running your own public Sorin instance entails the following, all of which is explained in detail below:

**Setting up external dependencies:**

* Creating Google authentication keys
* Creating an Amazon AWS IAM role, keys for it, and an S3 bucket it has privileges on
* Creating a WorldCat WSKey for Sorin to use (or keys for another search target, if you're starting with a different one)

**Installing Sorin on a local machine for experimentation and customization:**

* Installing Elixir and Phoenix and their dependencies, along with PostgreSQL, on a (preferably local) development machine
* Forking/cloning Sorin from GitHub and using simple commands to download and install its dependencies
* Editing certain Sorin configuration files for your organization
* Lightly adapting a built-in script and running it to populate your local database with test data. You'll now have a complete and fully functional Sorin instance running on your local machine, and will be able to log in, kick the tires, and iterate further on customizations and extensions, if you wish.

**Building for Production:**

* Setting up your production server with Phoenix and all of its dependencies
* Installing and configuring PostgreSQL on your server
* Cloning your edited, customized, production-ready Sorin repo onto the server and copying over all configuration files you have in `.gitignore`
* Using an Elixir shell command to migrate your database schema to PostgreSQL
* Using a few Elixir shell commands to compile your Sorin instance to a self-contained Erlang package

**Deploying to Production:**

* Generating a csv file of the user accounts you want to populate your instance with, and putting the file on your production server
* Copying the compiled Erlang package from your build directory to wherever you want to run it from
* Firing it up! :rocket:
* Running a single command from its console interface to populate it with user accounts from your csv file

We will attempt to document these processes as well as we can -- pull requests are very welcome!

## Local installation for development

### External dependencies

Sorin is currently hard-coded to use two external services: [AWS S3](https://aws.amazon.com/s3/) for storage of file attachments, and [Google OAuth](https://github.com/ueberauth/ueberauth_google) for user authentication. It's on the road map to introduce a configurable layer of abstraction for these two services, but for now, you will need an S3 bucket set up for file attachments, and your user account email addresses must be Google accounts (Google accounts that use a custom domain name are fine). See [Appendix I - Setting up Google Auth](#appendix-i-setting-up-google-auth) and [Appendix II - Introduction to S3](#appendix-i-introduction-to-s3)  for help with getting these set up.

Out of the box, Sorin's search bar is (minimally) set up with an [extension](#extensions) to query the [WorldCat Search API](https://www.oclc.org/developer/develop/web-services/worldcat-search-api.en.html). For this to work, you'll need to be able to supply your organization's  [WSKey](https://www.oclc.org/developer/develop/authentication/how-to-request-a-wskey.en.html). Please note that the WorldCat extension in its current form is only intended to provide example functionality -- if you intend to use WorldCat in production, you will probably want to extend and improve the extension, which we will be very happy to help with, if you get in touch. There is also a much more polished extension available for [Primo](#https://www.exlibrisgroup.com/products/primo-library-discovery/) that's in production at St. Edward's -- and it's also possible to create all new search target extensions for anything that has a search-related API.

### Internal dependencies

Sorin uses Elixir's leading web framework, [Phoenix](https://phoenixframework.org/). The [Phoenix documentation site](https://hexdocs.pm/phoenix/installation.html) has great instructions for getting Phoenix and all of its dependencies installed and working, so we recommend starting there. Sorin has no other local dependencies except those that will be automatically downloaded and installed as part of the compiling process later on. Make sure you have all of the following installed and working correctly per the instructions:

* Erlang/OTP
* Elixir
* Phoenix
* Node.js (with npm!)
* PostgreSQL

### Setting up your local development instance

1. If you have not already done so, use [Phoenix's guide](https://hexdocs.pm/phoenix/installation.html) to get all of your Phoenix dependencies installed and working
2. Fork and clone Sorin and `cd` into the cloned repo
3. Make all necessary configuration changes as detailed in the next section, [configuration and customization](#configuration-and-customization.md)
4. From the root of your Sorin repo, pull in and compile Sorin's Elixir dependencies:

```sh
$ mix deps.get && mix deps.compile
```

5. Create your local development database:

```sh
$ mix ecto.setup
```

6. Install Sorin's npm dependencies:

```sh
$ cd apps/frontend/assets && npm install && cd -
```

### Seeding your local development database

At this point, assuming there have been no errors, your Sorin instance is ready to run, and if you start up the Elixir command shell now, you'll have full access to all of the functionality of the system. You can even start up the web interface -- though at this point, you won't have any users you can log in with. If you have already set up your `seeds.exs` script as described in the [configuration and customization](#configuration-and-customization.md) section, you can use it now to seed your local database with temporary example data:

```sh
$ mix run apps/core/priv/repo/seeds.exs
```

You will see some data scroll by as Elixir's `mix` tool runs the commands in `seeds.exs` to populate your local database. Assuming success, you are now ready to start your server.

### Running the application

To start Sorin's web-based front end and access it in your browser, execute the following from the application root:

```sh
$ mix phx.server
```

To run it in only in Elixir's command shell:

```sh
$ iex -S mix
```

To start both, if you want to interact with it in your browser and at the command line:

```sh
$ iex -S mix phx.server
```

After webpack compiles all of your javascript and css, you'll be able to access your server at http://localhost:4000/

**Congratulations, you're up!**

## Configuration and Customization

Sorin configuration takes place in five places:

* `sorin.exs` is Sorin's main configuration file, located in the application root
* `apps/core/priv/repo/seeds.exs` is a script that populates your local development database with temporary data just for experimentation, learning, and development
* `apps/core/config/` is where you'll find the configuration files for establishing connections to your development and production PostgreSQL databases
* `apps/api/config/` is where you'll find the configuration files for managing Sorin's API. For now, all that's needed is to add [your Google OAuth keys.](#appendix-i-setting-up-google-auth)
* `apps/frontend/config/` is where you'll find the configuration files for managing Sorin's front end.

Sorin is also customizable via extensions, which won't be listed or described here in detail; but two extension in particular you may want to consider:

* [SorinTheme](https://github.com/seulibrary/Sorin-Theme), which makes it possible to edit Sorin's interface;
* [SorinSearchFilter](https://github.com/seulibrary/Sorin-Search-Filter), which adds customizable search filtering.

### 1. sorin.exs

`sorin.exs` is Sorin's main configuration file. Because you will need to populate it with sensitive information, we have added it to the repo's `.gitignore` file, so the first thing you'll need to do is make your own new copy of it from our template:

```sh
$ cp sorin_example.exs sorin.exs
```

Make sure never to check this file into version control!

`sorin.exs` is an Elixir file with several sections labeled `config`, such as this one:

```elixir
config :worldcat,
  wskey: "WSKEYGOESHERE",
  result_format: "&recordSchema=info%3Asrw%2Fschema%2F1%2Fdc"
```

We think of these as _stanzas_, each comprising a list of _keys_ you'll add _values_ to, though the structure of some of them is a bit more complicated. There can be one stanza per Sorin _application_, which in this case is a term of art referring to the self-contained Elixir applications contained within the `apps` and `deps` directories. We will not usually need to supply configuration stanzas for the applications in the `deps` directory, but note that Sorin [extensions](#extensions) are really just applications in the `deps` directory along with Sorin's other dependencies.

`sorin.exs` is pre-populated with all of the stanzas needed to get Sorin running, and can be completed by just replacing the dummy values for each key with the correct values for your instance.

**search**

```elixir
config :search,
  search_target: Worldcat
```

This stanza configures the `apps/search` application. It only has one key, `search_target`, which is prepopulated with the only search target extension Sorin comes with out of the box, Worldcat. Unless you intend to install the extension for another search target, such as Primo, right away, you can leave this one alone. 

**frontend**

```elixir
config :frontend,
  settings: %{
    # Caution: these settings will be visible in the browser!
    app_name: "Sorin",  
    url: "https://your_url.edu",
    admin_email: "",
    api_port: 8080}
```

The `frontend` stanza's keys are a special case because, in order to be available to front end HTML and JavaScript, they must be contained in their own `settings` key. Within the `settings` area, however, all keys and values work normally.

* `app_name` is where you can set a name for your instance that will show up in the browser interface's header and title bars. This can be left as-is, or, if you rename your instance, make sure to keep the name within double quotes.
* `api_port` determines the port your Sorin server's REST API will be listening on. This can be left alone as long as the default port is available to you.
* `url` and `admin_email` are currently not actually used; they're held in place for future development.

**worldcat**

```elixir
config :worldcat,
  wskey: "WSKEYGOESHERE",
  result_format: "&recordSchema=info%3Asrw%2Fschema%2F1%2Fdc"
```

This stanza configures the preinstalled Worldcat extension, and only needs values for two keys:

* `wskey` is where you'll enter your WorldCat account's [WSKey](https://www.oclc.org/developer/develop/authentication/how-to-request-a-wskey.en.html), between the double quotes, replacing `WSKEYGOESHERE`
* `result_format` refers to WorldCat's "recordSchema" SRU parameter, documented [here](https://www.oclc.org/developer/develop/web-services/worldcat-search-api/bibliographic-resource.en.html). This value can be left as-is.

**ex_aws**

```elixir
config :ex_aws,
  access_key_id: "ACCESSKEYIDGOESHERE",
  secret_access_key: "SECRETACCESSKEY",
  region: "REGIONNAME",
  bucket: "BUCKETNAME",
  link_root: "https://s3.amazonaws.com/your_bucket/",
  disk_quota: 1000000000 # 1 gigabyte
```

[ExAws](https://github.com/ex-aws/ex_aws) is an Elixir library Sorin uses to access Amazon's S3. After you have set up an AWS [IAM](https://aws.amazon.com/iam/) user for Sorin, you can populate the `access_key_id` and `secret_access_key` fields with your IAM keys. The `region`, `bucket`, and `link_root` can be populated once you have created and configured your Sorin bucket. 

Of special note is `disk_quota`: this is where you set the maximum amount of storage each user has for file attachments, in bytes. This field is set by default to `1000000000`, which is 1 gigabyte, but you can adjust it to whatever you want. 

**secret_key_base**

```elixir
### Secret keys

secret_key_base = ""

config :api, ApiWeb.Endpoint,
  secret_key_base: secret_key_base

config :frontend, FrontendWeb.Endpoint,
  secret_key_base: secret_key_base
```

The last section, `secret_key_base`, is where you'll enter a secret token used by both the API and frontend applications. There are three parts: a variable assignment, and the use of the variable in the configuration stanzas for the api and frontend applications.

You don't have to worry about the latter two parts, but you do need to create a secret key for the first part. From the root of your application:

```sh
$ mix phx.gen.secret
```

Mix will output a long, random-looking string of characters. Enter them into your sorin.exs:

```elixir
secret_key_base = "gSAe1XGh7nWTT1v93pYU0etISmZ8vPpQkEel+tL2fP/frvXCCyDI7GfkMmcFuIOG"
```

### 2. The database configuration files

`apps/core/config` holds three configuration files and two example configuration files. `config.exs` doesn't concern us here and can be left alone. The remaining files are intended to be populated with the information necessary for connecting Sorin to its Postgres databases, production and development. Because these files will hold protected login credentials, `prod.exs` and `dev.exs` only do one thing each: import `prod.secret.exs` and `dev.secret.exs` respectively, which are listed in `.gitignore` so your credentials don't end up in version control. 

So, as with `sorin.exs` above, your first step will be two create your `prod` and `dev` secret files from the examples:

```sh
$ cp prod.secret.example.exs prod.secret.exs && cp dev.secret.example.exs dev.secret.exs
```

The fields you'll have to edit in each file are `username` and `password`, which you will have created as part of your Phoenix installation earlier; but note that you only need to populate `prod.secret.exs` on your production server and `dev.secret.exs` on your local development instance. On each machine, the other secret file can be left unedited.

### 3. seeds.exs

`apps/core/priv/repo/seeds.exs` is an Elixir script used to populate your local development database with temporary content for testing and experimentation. We have set it up to use the same back end commands that are called by Sorin's front end, which makes it also serve as an incomplete suite of ad hoc integration tests (with the exception of resource creation, which would be pretty awkward if it depended on actual searches and saves).

You are welcome to browse through and modify this script however you like; you should find it pretty readable even without much knowledge of Elixir.

**There is just one section that's mandatory to edit,** if you intend to log into the front end. From line 15:

```elixir
##################################
#  ADD USERS
############
[
  ["user1@email.com", "User 1"],
  ["user2@email.com", "User 2"],
  ["user3@email.com", "User 3"],
]
```

You can rename the user accounts in this stanza (e.g., replace "User 1" with "Mouse, Minnie"), but because Sorin's front end uses Google OAuth for authentication, if you want to be able to log into the front end of your development instance, the email addresses must be active Google accounts, and you will only be able to authenticate with accounts you have passwords for -- so, at least one of the user accounts should be one of your Gmail accounts. Note that this is only for your local development instance.

As currently written, `seeds.exs` creates three user accounts, each of which has one default "Inbox" collection; it then creates six more collections, two per user, for a total of nine collections (though at the end of the script some of those collections are cloned and imported, increasing the collection count). Because much of the rest of the script edits those first nine collections by their `id` values, if you create more or fewer user accounts in the beginning, those `id` values will be different and will need to be updated accordingly.

### 4. The API configuration files

`apps/api/config` holds four configuration files and two example configuration files. `config.exs` and `test.exs` don't concern us here and can be left alone. As with the database files and sorin.exs above, you will want to create your secret files from the examples:

```sh
$ cp dev.secret.example.exs dev.secret.exs && cp prod.secret.example.exs prod.secret.exs
```

**Secret Files**

In each new secret file, you will find just one stanza:

```elixir
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "[CLIENT_ID]",
  client_secret: "[CLIENT_SECRET]"
```

You can populate these fields with keys created in your Google developer console, as described in [Appendix I - Setting up Google Auth](#appendix-i-setting-up-google-auth). If you intend to do any serious hacking on Sorin, we can suggest using different keys in your dev and prod modes; but this is optional.

**prod.exs**

Our last API configuration is to `prod.exs`. The first stanza looks like this:

```elixir
config :api, ApiWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 8080],
  url: [host: "", port: 8080],
  cache_static_manifest: "priv/static/cache_manifest.json"
```

All you need to do is enter your hostname:

```elixir
config :api, ApiWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 8080],
  url: [host: "https://stedwards.edu", port: 8080], # Updated host
  cache_static_manifest: "priv/static/cache_manifest.json"
```

### 5. The front end configuration files

All you need to do for the front end is update one stanza in one file. `apps/frontend/config/prod.exs` looks like this:

```elixir
config :frontend, FrontendWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4000],
  url: [host: ""],
  cache_static_manifest: "priv/static/cache_manifest.json"
```

As with the API application, you need to update your host name:

```elixir
config :frontend, FrontendWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4000],
  url: [host: "https://stedwards.edu"], # Updated host
  cache_static_manifest: "priv/static/cache_manifest.json"
```

## Creating production releases

As this documentation is being written, development of Elixir 1.9, which adds native functionality for release building, is being wrapped up; but Sorin currently uses the popular Elixir library [Distillery](https://github.com/bitwalker/distillery) for that purpose. The creation and configuration of Erlang releases is a potentially complex subject that, if you decide to put Sorin into production, [you may need to spend some time with](https://hexdocs.pm/distillery/home.html), but the following should get you started.

As a reminder, the following assumes that you are building your release and deploying it on the same machine, and that your production instance of PostgreSQL is running on the same machine as well.

[Also please note that for simplicity and clarity, version control -related commands and best practices have been omitted; it is assumed though that you are using separate repos or branches to accommodate the slightly different configurations of your production instance from your dev.]

### 1. Initialize Distillery

From your application root:

```sh
$ mix release.init
```

Distillery will create a `rel/` directory that will hold all files related to your release. 

### 2. Configure your release

Your release's configuration file is `rel/config.exs`. This file will be pre-populated with some default values you can mostly leave alone. 

You will find stanzas for configuring `dev` and `prod` environments. Unless you plan to compile a `dev` release, you can delete the `dev` stanza now. 

The remaining `prod` stanza includes a cookie you can use later to connect Erlang's native system monitor to your running instance, but for now note `include_erts` and `include_src`:

```elixir
environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"[cookie]"
end
```

`erts` refers to the Erlang runtime: if you include the Erlang runtime in your release, you can move it to any other machine with the same architecture and operating system and run it even if Erlang and Elixir are not installed. For now, assuming you're building this release on the machine you're deploying on, there's no need to include `erts` or `src`:

```elixir
environment :prod do
  set include_erts: false
  set include_src: false
  set cookie: :"[cookie]"
end
```

Also note the final stanza:

```elixir
release :sorin do
  set version: current_version(:sorin)
  set applications: [
    :runtime_tools,
    api: :permanent,
    core: :permanent,
    frontend: :permanent,
    search: :permanent
  ]
end
```

You will want to update the `version` line to a specific version number. You can set the version number arbitrarily or according to your own versioning scheme, enclosed in double quotes:

```elixir
release :sorin do
  set version: "0.1.0"
```

Whatever you set here will be applied to your release, and since it is cheap to produce and switch between releases, you may find yourself versioning frequently: each time you bump the version running in production, just bump the version number in `rel/config.exs`.

### 3. Prepare and build the release

Not all of the following instructions will be necessary every time you build a release, but they are all included to be comprehensive. From your application root:

1. Get and compile Sorin's Elixir dependencies:

```sh
$ mix deps.get && mix deps.compile
```

2. Switch to the frontend assets directory and get and compile Sorin's JavaScript dependencies:

```sh
$ cd apps/frontend/assets && npm install && npm run-script prod-build
```

3. When the installation is complete, change back to the application root and build Sorin's Phoenix site:

```sh
$ cd - && MIX_ENV=prod mix phx.digest
```

4. When the Phoenix digest is complete, build your release:

```sh
$ MIX_ENV=prod mix release
```

If all has gone according to plan, you will now have a release packaged up at `_build/prod/rel/sorin/releases/[VERSION]/sorin.tar.gz`! The output of the `release` command will include commands you can optionally run from your application root to test the system prior to deploying the release to its future production home.

## Deploying

The first time you deploy Sorin to production, there will be three steps:

1. Set up the database
2. Start Sorin's release
3. [Populate the database with user accounts](#adding-users). 

Subsequent upgrades or redeployments only require stopping the current release and starting the next one, with database updates only required on major version upgrades that alter the core data model. User accounts can be added to a running instance at any time, following [the instructions below.](#adding-users)

### 1. Set up the database

If PostgreSQL has been installed and is running, and if Sorin [has been configured for it correctly](#configuration-and-customization), you can create and set up Sorin's database by running the following from your application root:

```sh
$ MIX_ENV=prod mix ecto.setup
```

The `MIX_ENV=prod` part tells Elixir's build tool, mix, to use the database configurations contained in `apps/core/config/prod.exs` (which imports `apps/core/config/prod.secret.exs`).

### 2. Deploy and start Sorin

If you have created a release on your production server as described above, "deploying" is as simple as moving the tarball to wherever you want to run it from, untarring it, and starting it. As described in [Distillery's fine documentation](https://hexdocs.pm/distillery/introduction/walkthrough.html), 

```sh
$ mkdir -p /var/sorin # Or wherever
$ cp _build/prod/rel/sorin/releases/[VERSION]/sorin.tar.gz /var/sorin/
$ pushd /var/sorin
$ tar -xzf sorin.tar.gz
$ bin/sorin start
```

To stop it:

```sh
$ bin/sorin stop
```

To connect an Elixir command shell to the running release:

```sh
$ bin/sorin remote_console
```

## Adding users

Adding user accounts is still a pretty unpolished manual process (we're working on it!). The bad news is that it depends on a csv file listing the user accounts you want to add; the good news is that populating is easy if you have the file.

### Structure of the csv file

Sorin requires the csv file to be built with one row per user and two fields per row, structured as:

```
email,"fullname"
```

...That is, a full email address as the first field, and a full name in double quotes as the second field. The full name can be structured or populated however you want it to appear in the front end. Example:

```
akosarek@stedwards.edu,"Kosarek, Alex"
mherna14@stedwards.edu,"Hernandez, Marcos"
rgibbs@stedwards.edu,"Gibbs, Robert Casey"
```

**Note: email addresses must be unique in the database.**

Once the csv file has been created, it can be placed anywhere on the production server that's accessible by the user you'll be running Sorin as.

### Populating accounts from the csv file

To populate user accounts, `cd` into the directory containing your running release, and attach a console:

```sh
$ bin/sorin remote_console
```

Then run the following command:

```elixir
iex(1)> Core.Accounts.sync_from_csv("/path/to/csv")
```

Once the accounts have been created, you can exit the console by typing `Ctrl+c` twice.

The script will ignore any email addresses that already exist in the database, so it can be run any number of times with any lists of users, and will create accounts for any rows with unknown email addresses. Scripted account removal/update will not be implemented until version 0.2.0, though accounts can be removed or updated manually at any time.

## Extensions

What we call "extensions" are modular, self-contained Elixir sub-applications that can be added to your instance of Sorin to extend or modify aspects of its operation. Some extensions are cosmetic, such as the forthcoming sorin-theme extension that enables you to dress up your instance with custom HTML, CSS, and JavaScript. Some extensions are more fundamental -- for example, to keep Sorin generically useful for all kinds of cataloging systems, search targets, such as WorldCat or Primo, are implemented as extensions.

Because extensions are complete Elixir applications, they can be installed just as, and alongside, Sorin's other Elixir dependencies [as described here.](https://hexdocs.pm/mix/Mix.html#module-dependencies) At a high level, the basic installation process only has two steps:

1. Add the extension to your application root's mix.exs file:

```elixir
defp deps do
    [
      {:sorin_primo, github: "sorin/sorin_primo"},
    ]
end
```

2. Download and compile it. From your application root:

```sh
$ mix deps.get && mix deps.compile
```

**In practice, extensions will frequently require additional installation steps.** Most extensions will require configuration keys and values to be added to your sorin.exs [as described above](#configuration-and-customization), and any extensions that add or change any content visible in the browser will also require custom mix tasks to correctly populate the front end application. For complete installation and configuration instructions, always see the `README.md` file for the extension.

## Appendix I - Setting up Google Auth

**Setting up your Google account for your application:**

1. Log into the Google Developer Console: https://console.cloud.google.com/
2. Click **Select your project**
3. Select **New project**
4. Fill out your "Project Name" with something applicable, e.g. "Sorin," or whatever you name your instance of Sorin
5. Click **Create**
6. Once it has been created, select the App from **Select your project**
7. From the side menu (or hamburger) click on **APIs & Services**
8. Click on **Library**
9. Search for and enable **Google Drive API**
10. After adding, click on the back arrow at the top left, and click **Credentials**

**Applying the enabled APIs:**

1. Click on **OAuth consent screen**
2. Under "Scopes for Google APIs" click, **Add scope**
3. Search for "Google Drive API"
4. Click on the boxes for
```
Google Drive API | ../auth/drive.file
Google Drive API | ../auth/drive.appdata
```

...and click **Add** at the bottom.

On this page, you will also want to fill out the other fields to better help your users understand who is able to access their information and what they're able to do with it.

When you're done, go back to "Credentials"

5. Click **Create credentials**
6. Select **OAuth Client ID**
7. Select **Web Application** as the Application type
8. Create a name you will remember and can tell apart from other keys.
9. When you're done, you will be supplied the client Id and client secret needed for [your api config files.](#configuration-and-customization)
10. Click on the edit icon for the recently created client Id. 

If this is a dev version you will need to also include:

```
Origins:
http://localhost:4000

Redirects:
http://localhost:4000/auth/google/callback
```

If it's for production:

```
Origins:
http://[your-site-url]

Redirects:
http://[your-site-url]/auth/google/callback
```

## Appendix II - Introduction to S3
We will not describe in detail the whole process of setting up an Amazon account to use S3 securely, but by way of introduction for beginners, S3 ("simple storage service") is a reliable and inexpensive service provided by Amazon for storing files on their servers. Anyone with an Amazon account can log in to https://aws.amazon.com/console/ and set up an S3 "bucket" and get started, though for better security, it's often recommended to create a new user record within the account and delegate to it only the privileges needed to operate that one bucket. 

In high-level overview, the process might look like this:

* Create an Amazon account, or log into an existing one, [here](https://aws.amazon.com/console/)
* Use [the S3 section of the AWS console](https://s3.console.aws.amazon.com/s3/) to create a bucket solely for Sorin
* Use [the IAM section of the AWS console](https://console.aws.amazon.com/iam) to create an IAM "role," that only has privileges on your Sorin bucket
* Populate the `:ex_aws` stanza of your Sorin instance's `sorin.exs` with the relevant data from your S3 bucket and IAM role:

```elixir
config :ex_aws,
  access_key_id: "[Access key from your IAM role]",
  secret_access_key: "[Secret key from your IAM role]",
  region: "[Region of your S3 bucket]",
  bucket: "[Name of your S3 bucket]",
  link_root: "https://s3.amazonaws.com/[Name of your bucket]/",
```

Amazon's documentation for these services and processes can be found:

* [here for S3](https://docs.aws.amazon.com/AmazonS3/latest/gsg/GetStartedWithS3.html)
* [here for IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)

There are many tutorials on the open web as well. If you are new to AWS, IAM, or S3, we recommend reserving enough time to make sure you set yourself up according to recommended best practices and are comfortable with your arrangement.

## Appendix III - Theming with SorinTheme

The default interface of Sorin is fairly dry. To dress it up and adapt it to your organization, you will want to install the [SorinTheme extension](https://github.com/seulibrary/Sorin-Theme). SorinTheme is a work in progress -- pull requests welcome!
