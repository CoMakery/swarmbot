# Swarmbot

Latest build: [![Travis CI](https://travis-ci.org/citizencode/swarmbot.svg?branch=master)](https://travis-ci.org/citizencode/swarmbot)

Issue board: [![Waffle](https://badge.waffle.io/citizencode/swarmbot.svg?label=on%20deck&title=On%20Deck)](http://waffle.io/citizencode/swarmbot)

## Project Vision

Swarmbot hangs out in Slack and creates Project Coins on a trusty blockchain.
It helps you to distribute profit and tracks your fair share of projects you work on.
Swarmbot helps you run a [Dynamic Equity Organization](https://github.com/citizencode/dynamic-equity-organization).


## Current Implementation Status

This project is alpha and not ready for production use.
It is being actively developed by [Citizen Code](http://citizencode.io/).
We welcome [feature requests and pull requests](https://github.com/citizencode/swarmbot/issues).

We are planning to license it as a Dynamic Equity Organization.
The structure is being legally reviewed for use in Swarmbot and on your projects.

To learn more when we release it, sign up for our mailing list over at [www.swarmbot.io](http://www.swarmbot.io/)

## Here's What Swarmbot Can Do

![Swarmbot UX](https://cdn.rawgit.com/citizencode/swarmbot/101569b44d0decd29fdbb05efe55501522262330/doc/examples-2015-12/flow.png)

## Development

The Swarmbot is based on [Hubot](http://hubot.github.com),
and is configured specifically for Slack.

    npm install

You can start the bot locally by running:

    npm run devbot

This will also load environment variables from your local `.env` file.

## Deploying

### Heroku Deploy

```sh
heroku create
heroku addons:create redistogo:nano  # Optional. Colu caches to Redis if available.
heroku addons:create airbrake:free_heroku  # error reporting, optional
git push heroku master
heroku ps:type hobby  # will be available 24/7, but costs $
```

### Set environment variables

```sh
HUBOT_SLACK_TOKEN  # your slack token, from Slack -> Integrations -> Hubot

COLU_PRIVATE_SEED    # register at https://dashboard.colu.co/register
COLU_NETWORK         # testnet or mainnet
COLU_MAINNET_APIKEY  # if on mainnet

FIREBASE_URL       # visit https://www.firebase.com/ to create DB
FIREBASE_SECRET    # found in the "Secrets" tab of your Firebase instance

KEENIO_PROJECT_ID  # keen.io analytics, optional
KEENIO_API_TOKEN   #

AIRBRAKE_API_KEY   # Airbrake error reporting, optional

APP_NAME           # friendly app name for keen.io, airbrake, etc

NODE_ENV=production         # recommended settings for Node on Heroku
NODE_MODULES_CACHE=false    #
NPM_CONFIG_PRODUCTION=true  #

DEBUG=app          # for verbose debugging info in logs
```

## License

Swarmbot is being developed under the experimental
[Peer Production Royalty Token License](https://github.com/citizencode/swarmbot/blob/master/LICENSE.md).
