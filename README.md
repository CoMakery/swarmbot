# Swarmbot

Latest build: [![Travis CI](https://travis-ci.org/citizencode/swarmbot.svg?branch=master)](https://travis-ci.org/citizencode/swarmbot)

Issue board: [![Waffle](https://badge.waffle.io/citizencode/swarmbot.svg?label=on%20deck&title=On%20Deck)](http://waffle.io/citizencode/swarmbot)

## Project Vision

Swarmbot is a bot designed to help automate the creation of community
collaboration pods with their own digital currency,
create bounties within those pods,
and transfer assets to a person deemed to have successfully achieved the bounty.

In more detail:

1. Users can create a new collaboration group known as a _community_
  - A new _community coin_ is automatically created for the community
1. A community member can propose a _bounty_ within that community
1. The community can choose which bounties to devote resource toward
1. At the discretion of the community, the bounty can be either:
  - Competition style (X-Prize model)
  - Claim style (trusted community member may claim first right to completing
    bounty)
1. Community member completes the bounty's underlying task or project
1. Community representatives votes on whether or not to award the bounty to this
   community member
1. If the bounty work is approved, the member is payed in community coins

## Current Implementation Status

This project is in very early stages, and not ready for production use.
It is being actively developed by [Citizen Code](http://citizencode.io/).
We welcome [feature requests and pull requests](https://github.com/citizencode/swarmbot/issues).

The Swarmbot is based on [Hubot](http://hubot.github.com).
It is configured by default to run with the Hubot Slack adaptor,
but is easily configured to work anywhere Hubot works.

## For Example

### View All Tasks & Choose Task

![](https://cdn.rawgit.com/citizencode/swarmbot/e8e0e7b7f21346f69cac7882eb29613778098a39/doc/examples-2015-10/choose-proposal.png)

### Upvote a Task

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/proposal-upvote.png)

### Set a Bounty on a Task

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/set-bounty-1.png)
![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/set-bounty-2.png)

### Create a Solution to a Task

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/solution-create.png)

### The Community Creator Receives Notification of New Solutions

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/notification-of-solution.png)

### Set Payment Address

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/bitcoin-set.png)

### Request a Feature

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/feature-request.png)

## Development

    npm install

You can start the bot locally by running:

    npm run dev

If you wish to load environment variables from a local `.env` file:

    env `cat .env` npm run dev

## Deploying

### Heroku Deploy

```sh
heroku create
heroku ps:type hobby  # will be available 24/7, but costs $
heroku addons:create redistogo:nano
heroku addons:create airbrake:free_heroku  # error reporting, recommended
git push heroku master
```

### Set environment variables

```sh
HUBOT_SLACK_TOKEN  #your slack token, from Slack -> Integrations -> Hubot

COLU_PRIVATE_SEED
COLU_NETWORK (testnet|mainnet)
COLU_MAINNET_APIKEY  # if on mainnet

FIREBASE_URL
FIREBASE_SECRET

DEBUG=app  # for verbose debugging info in logs

# optional:
HUBOT_INSTAGRAM_ACCESS_KEY
HUBOT_INSTAGRAM_CLIENT_KEY
```

### Code Notes

|Naming            |                  |                  |                 |
|------------------|:----------------:|:----------------:|:----------------:
|Current interface |project           |task              |solution         |   
|Current DB        |project           |proposal          |solution         |
|Cruft in code     |DCO               |proposal          |N/A              |

## License

Swarmbot is being developed under the experimental [Peer Production Royalty Token License](https://github.com/citizencode/swarmbot/blob/master/LICENSE.md).
