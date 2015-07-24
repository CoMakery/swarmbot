# hubot-rules

A hubot script that explains the rules

See [`src/rules.coffee`](src/rules.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-rules --save`

Then add **hubot-rules** to your `external-scripts.json`:

```json
[
  "hubot-rules"
]
```

## Sample Interaction

```
user1>> hubot what are the rules
hubot>> 1. A robot may not injure a human being or, through inaction, allow a human being to come to harm.
hubot>> 2. A robot must obey any orders given to it by human beings, except where such orders would conflict with the First Law.
hubot>> 3. A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.
```
