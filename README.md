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

### View All Proposals & Choose Proposal

![](https://cdn.rawgit.com/citizencode/swarmbot/e8e0e7b7f21346f69cac7882eb29613778098a39/doc/examples-2015-10/choose-proposal.png)

### Upvote a Proposal

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/proposal-upvote.png)

### Set a Bounty on a Proposal

![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/set-bounty-1.png)
![](https://cdn.rawgit.com/citizencode/swarmbot/46feaa44597a47c160cafd3c8dc37fa077f4c336/doc/examples-2015-10/set-bounty-2.png)

### Create a Solution to a Proposal

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

## Social Contract License

Swarmbot is the first implementation of the [Social Contract License](https://github.com/fractastical/distributed-governance/blob/master/social_contract_license.md).
