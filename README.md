# Right Branch

[![Build Status](https://travis-ci.org/DyegoCosta/right_branch.svg?branch=master)](https://travis-ci.org/DyegoCosta/right_branch)

Currently GitHub does not support switching the target branch of a Pull Request. This tool helps to do that in case a PR is submitted against a wrong branch.

## Getting started

Install gem:

```
$ gem install right_branch
```

Usage:

```
Usage: right_branch [options]
    -u, --username USERNAME          Username
    -r, --repository REPOSITORY      Repository
    -b, --new-branch NEW_BRANCH      New branch
    -p, --pull-request PULL_REQUEST  Pull request
        --password PASSWORD          Password
```

You can also use environment variables to use a default `username` and/or `repository`:

```
  $ export RIGHT_BRANCH_USERNAME=your_default_username
  $ export RIGHT_BRANCH_REPOSITORY=your_default_repository
```
