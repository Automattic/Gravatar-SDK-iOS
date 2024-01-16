# Your Ruby Environment

Some of the tools we use to manage this repo are written in Ruby.  These tools often require us to run under a
specific version of Ruby, and to install various RubyGems, again with specific versions.

While your computer likely includes with a version of Ruby installed out of the box, it can be very helpful to keep a separate Ruby
environment for tasks related to this repository.

To manage different Ruby versions, we recommend using a [Ruby Version Manager](#ruby-version-managers).

These are the main components of our toolset:

- [Ruby](https://www.ruby-lang.org/en/)
- [A Ruby Version Manager (e.g. rbenv)](https://github.com/rbenv/rbenv)
- [Bundler (dependency manager for Ruby)](https://bundler.io)
- [Cocoapods](https://github.com/CocoaPods/CocoaPods)
- [Homebrew](https://brew.sh)

## Quick Setup
There are more details below, but here's the TL;DR on getting set up:

First, we recommend that you install and use a Ruby version manager. These instructions will use `rbenv` because it is lightweight
and unintrusive.  Other Ruby version managers should work, though.

1. [Install `rbenv`](https://github.com/rbenv/rbenv#using-package-managers)
2. Install the version of Ruby used by this repository, specified in [.ruby-version](.ruby-version) (`rbenv install`)
3. Once the correct version of Ruby is installed, any commands that are run via `bundle` from within this repository will automatically use the version of Ruby specified in [.ruby-version](.ruby-version)
4. Run `bundle install`. This will install the project's Ruby Gem dependencies based on the `Gemfile`, using the versions locked in the `Gemfile.lock`
5. Use `bundle exec` to prefix any Ruby commands, such as `bundle exec rake`, `bundle exec fastlane` and so on

## Step by step
```shell script
# follow the instructions on https://github.com/rbenv/rbenv
brew install rbenv ruby-build

# follow the instructions to set up `rbenv` in your shell of choice (.zshrc is the default on macOS), then close terminal and open a new window

# change directory to the root of this repository
cd /path/to/gravatar-sdk-ios

# Install the version of Ruby used by this repo (as specified in the `.ruby-version` file)
rbenv install

# install the project's Ruby Gem dependencies
bundle install
```


<a name="ruby-version-managers"></a>
## Ruby Version Managers
There are a few popular Ruby version managers available.  Two of the more common options are:

- rbenv - https://github.com/rbenv/rbenv
- rvm - https://rvm.io

We highly recommend using a Ruby Version Manager, for several reasons. For example, the Ruby version that comes bundled with your OS will often not match the Ruby version we use in this repository. Replacing the Ruby version system-wide can cause unintended side effects on other system tools.  Additionally, other repositories may require different versions of Ruby. Lastly, keeping your ruby environments isolated from each other makes it easier to debug issues.

In fact, we likely won't provide support debugging Ruby environments that are using System Ruby, as our first step to fix such issues will be "use a Ruby Version Manager to solve your issue".

### Installing Gems: making it Easy With Bundler & Gemfiles

The `bundle` command uses the [Gemfile](Gemfile) and the
[Gemfile.lock](https://github.tumblr.net/TumblrMobile/orangina/blob/develop/Gemfile.lock) to provide an isolated ruby environment defined by those files.  The `bundle install` command uses this environment to install, update, and remove ruby gems from this environment.  The `bundle exec` command runs the command you pass to it within this isolated Ruby environment.

The `.bundle/config` in this repository configures the path into which bundler installs (and loads) Ruby Gem dependencies.
