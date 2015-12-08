# Swarmbot

Latest build: [![Travis CI](https://travis-ci.org/citizencode/swarmbot.svg?branch=master)](https://travis-ci.org/citizencode/swarmbot)

Issue board: [![Waffle](https://badge.waffle.io/citizencode/swarmbot.svg?label=on%20deck&title=On%20Deck)](http://waffle.io/citizencode/swarmbot)

## Project Vision

Swarmbot hangs out in Slack and creates Project Coins on a trusty blockchain. It helps you to distribute revenue and track your fair share of projects. Swarmbot helps you run a [Dynamic Equity Organization](https://github.com/citizencode/dynamic-equity-organization).


## Current Implementation Status

This project is in very early stages, and not ready for production use.
It is being actively developed by [Citizen Code](http://citizencode.io/).
We welcome [feature requests and pull requests](https://github.com/citizencode/swarmbot/issues).

We are planning to license it as a Dynamic Equity Organization. The structure is being legally reviewed for use in Swarmbot and on your projects.



## Here's What Swarmbot Does

![Swarmbot UX](https://cloud.githubusercontent.com/assets/7764167/11573372/c8362dc0-99ba-11e5-87c7-b698a3d07a3d.png)

## Development

The Swarmbot is based on [Hubot](http://hubot.github.com).
It is configured by default to run with the Hubot Slack adaptor,
but is easily configured to work anywhere Hubot works.

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
|Current interface |project           |award             |(depreacted)     |   
|Current DB        |project           |proposal          |solution         |
|Cruft in code     |DCO               |proposal, task    |solution         |

## License

Swarmbot is being developed under the experimental [Peer Production Royalty Token License](https://github.com/citizencode/swarmbot/blob/master/LICENSE.md).
