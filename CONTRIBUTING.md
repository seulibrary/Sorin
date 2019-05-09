# How to Contribute to Sorin

Welcome to the Sorin community, and thank you for your help! We welcome participation of almost any kind, including bug reports, feature or other suggestions, improvements to our code or documentation, and building new extensions. Please note that this project is released with a [Contributor Code of Conduct](code-of-conduct.md). By participating in this project you agree to abide by its terms.

## Reporting bugs or other issues

The best place to report a bug or other issue is Sorin's issue tracker. If you find that someone else has experienced the same or a related issue, you can help by adding a comment with any new details from your experience. If your issue is new, please provide as much information as possible for reproducing it: your operating system, the version of the software and its dependencies you're using, what extensions you have installed, and the steps required to reproduce the problem. Screen captures or videos are also helpful -- the more information you can provide, the faster the bug can be discovered and resolved.

## Providing Feedback

Sorin does not yet have a mailing list, forum, or IRC channel; as of now, the best way to provide us with general feedback and suggestions would be with the issue tracker or by emailing the developers in [AUTHORS.md](AUTHORS.md). We welcome any kind of feedback, and would be thrilled to hear about how it goes if you decide to experiment with it.

## New code

If you have improvements to Sorin, whether bug fixes or new features, please send us a pull request! GitHub has excellent documentation for the process [here](https://help.github.com/en/articles/about-pull-requests). The process will usually look like this:

1. Fork the master Sorin repo
2. Make your changes to the master branch, or to a new feature branch you'll merge into master before submitting the pull request
3. Include one or more unit tests that demonstrate a successful resolution of the fix or feature
4. Add yourself to [AUTHORS.md](AUTHORS.md)
5. Issue the pull request!

In general, code contributed to Sorin should:

* Use comments to describe non-obvious logic
* Include function-level documentation formatted for [ExDoc](https://hexdocs.pm/ex_doc/readme.html)
* Have already been formatted by the [native Elixir formatter](https://hexdocs.pm/mix/master/Mix.Tasks.Format.html)
* Optimize for obviousness and simplicity, rather than terseness, speed, or cleverness.

The development staff at Munday Library is small and resource-constrained and Sorin is quite new. Please have patience with us as we learn how to make this process as welcoming and effective as it can be. If Sorin knocks your socks off and you'd like to get more actively involved, please consider joining us as [maintainers](https://opensource.guide/best-practices/)! We need all the help we can get.
