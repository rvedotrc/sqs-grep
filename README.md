sqs-grep
========

Find messages on an SQS queue by regular expression, and optionally delete
them.

Installation
------------

```
  gem build sqs-grep.gemspec
  gem install sqs-grep*.gem
```

Use
---

Examples. (Note the use of the pattern "^" to match all messages).

```
  # Show all messages, delete nothing:
  sqs-grep ^ name-of-queue

  # Show only messages matching the given pattern, without deleting them:
  sqs-grep "[Ee]xception.*at line" name-of-queue

  # Show and consume (delete) all messages (somewhat like sqs-receive):
  sqs-grep --delete ^ name-of-queue

  # Show and consume (delete) only messages matching matching some pattern:
  sqs-grep --delete 1caf7fdb-e47a-46af-b8e3-4d955883a396 name-of-queue
```

More options are available; see `sqs-grep --help`.

sqs-grep can also be used as a Ruby library.  See `bin/sqs-grep` for a
guide for how to do this.

