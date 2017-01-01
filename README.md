## jigit

[![Build Status](https://travis-ci.org/Antondomashnev/jigit.svg?branch=master)](https://travis-ci.org/Antondomashnev/jigit)
[![codebeat badge](https://codebeat.co/badges/05115118-11ff-49bb-9b84-73070afb0f3c)](https://codebeat.co/projects/github-com-antondomashnev-jigit)
[![Gem Version](https://badge.fury.io/rb/jigit.svg)](https://badge.fury.io/rb/jigit)

Keep you JIRA issue statuses in sync with what you're doing actually.

### How it works?

If you're as lazy as me and in the same time working with JIRA for quite a time on a daily basis,
`jigit` may save you some time and make the process a bit better :wink
Let's say you've just cloned a project and
have 2 JIRA issues in `TO DO` in our list: `CNI-1798`, `CNI-1799`.

* You're on `master` branch or whatever you have as a default after cloning;
* You're going to work on `CNI-1798` first;
* `git checkout -b CNI-1798`;
* `jigit` will change the status of `CNI-1798` on JIRA to `In Progress`
  or whatever you set up as a `work in progress` status 🎉;
* Suddenly you have to switch to the higher priority `CNI-1799`;
* `git checkout -b CNI-1799`;
* `jigit` will ask you for a new status for `CNI-1798`, which I suppose a kind of `To Do`,
  and update status of `CNI-1799`;

And you can jump between branches as much as you want, but you will never ever have the wrong status for you JIRA issue :rocket.
You are 😀, a project manager is 😀 - the world becomes a bit better 🙌

### Example

If you want to see `jigit` in action, here we are:

![Alt text](https://monosnap.com/file/N55dJTlNbz3j3SP1KHBaO6gtwV20OM.png)

### Installation

```sh
$ [sudo] gem install jigit
```

Or via bundler:

```ruby
gem 'jigit', '~> 1.0'
```

The `jigit` gem requires `ruby-2.2.3` and currently can be installed
only on `OS X` because of a tight couple to `OS X keychain`.

### Getting started

The `jigit` configuration is guided by a friendly interviewer by the following command:  

```sh
$ bundle exec jigit init
```

After that step, you're set 🚀

### Limitation

Currently, `jigit` works only on `OS X`, requires `ruby-2.2.3`. Also, it's based on the git hooks
and therefore doesn't work with the source control UI app, but only by using `git` in the command line =)

### License

This gem is available under the MIT license.
