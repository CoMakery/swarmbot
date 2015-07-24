# hubot-diagnostics

hubot scripts for diagnosing hubot's current state.

See [`src/diagnostics.coffee`](src/diagnostics.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-diagnostics --save`

Then add **hubot-diagnostics** to your `external-scripts.json`:

```json
[
  "hubot-diagnostics"
]
```

## Sample Interaction

```
user1>> hubot ping
hubot>> PONG
user1>> hubot time
hubot>> 
```
