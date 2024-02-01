Contributing to Penlight
========================

So you want to contribute to Penlight? Fantastic! Here's a brief overview on
how best to do so.

## What to change

Here's some examples of things you might want to make a pull request for:

* New features
* Bugfixes
* Inefficient blocks of code

If you have a more deeply-rooted problem with how the library is built or some
of the stylistic decisions made in the code, it's best to
[create an issue](https://github.com/lunarmodules/Penlight/issues) before putting
the effort into a pull request. The same goes for new features - it might be
best to check the project's direction, existing pull requests, and currently open
and closed issues first.

## Using Git appropriately

Here's how to go about contributing to Penlight:

1. [Fork the repository](https://github.com/lunarmodules/Penlight/fork) to
your Github account.
2. Create a *topical branch* - a branch whose name is succinct but explains what
you're doing, such as _"added-klingon-cloacking-device"_ - from `master` branch.
3. Make your changes, committing at logical breaks.
4. Push your branch to your personal account
5. [Create a pull request](https://help.github.com/articles/using-pull-requests)
6. Watch for comments or acceptance

If you wanna be a rockstar;

1. Update the [CHANGELOG.md](https://github.com/lunarmodules/Penlight/blob/master/CHANGELOG.md) file
2. [Add tests](https://github.com/lunarmodules/Penlight/tree/master/tests) that show the defect your fix repairs, or that tests your new feature

Please note - if you want to change multiple things that don't depend on each
other, make sure you check out the `master` branch again and create a different topical branch
before making more changes - that way we can take in each change separately.

## Release instructions for a new version

  - create a new release branch
  - update `./lua/pl/utils.lua` (the `_VERSION` constant)
  - update `./config.ld` with the new version number
  - create a new rockspec file for the version in `./rockspecs`
  - check the `./CHANGELOG.md` files for completeness
  - commit the release related changes with `release x.y.z`
  - render the documentation using `ldoc .`
  - commit the documentation as a separate commit with `release x.y.z docs`
  - push the release branch and create a PR
  - merge the PR
  - tag the release as `x.y.z` and push the tag to the github repo
  - upload the rockspec, and source rock files to LuaRocks
  - test installing through LuaRocks
  - announce the release on the Lua mailing list

