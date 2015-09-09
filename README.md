# Swarmbot

Build: [![Circle CI](https://circleci.com/gh/citizencode/swarmbot/tree/master.svg?style=svg)](https://circleci.com/gh/citizencode/swarmbot/tree/master)

Swarmbot is a Hubot which allows you to create "bounties" and award them to people. It is nominally configured to run on Slack, but should work anywhere Hubot works, with minimal changes.

## Local development

You can start the bot locally by running:

    npm run dev

Or, if you wish to interface with the production database from your local machine:

    env `cat .env` npm run dev

## Social Contract License

Swarmbot is the first implementation of the [Social Contract License](https://github.com/fractastical/distributed-governance/blob/master/social_contract_license.md)
