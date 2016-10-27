# Swarmbot

Latest build: [![Travis CI](https://travis-ci.org/CoMakery/swarmbot.svg?branch=master)](https://travis-ci.org/CoMakery/swarmbot)

## Project Vision

Swarmbot hangs out in Slack and creates Project Coins on a trusty blockchain.
It helps you to distribute profit and tracks your fair share of projects you work on.
Swarmbot helps you run a [Dynamic Equity Organization](https://github.com/citizencode/dynamic-equity-organization).

## Current Implementation Status

Not currently under active development by the original authors. Feel free to fork and extend.

Check out our new ethereum based cryptoequity collaboration system at [comakery.com](http://www.comakery.com).

## Here's What Swarmbot Can Do

![Swarmbot UX](https://cdn.rawgit.com/CoMakery/swarmbot/101569b44d0decd29fdbb05efe55501522262330/doc/examples-2015-12/flow.png)

## Development

Project setup is pretty easy, make sure you have something close to these versions from Homebrew (make sure to run `brew update` first

`node -v` => v5.3.0

`npm -v` => 3.3.12

`redis-server -v` => Redis server v=3.0.7 ...


The Swarmbot is based on [Hubot](http://hubot.github.com),
and is configured specifically for Slack.

    npm install

You can start the bot locally by running:

    npm run devbot

Start a redis server

    redis-server

OR if you have foreman installed `gem install foreman`, you can start everything in one terminal

    foreman start -f Procfile.dev

This will also load environment variables from your local `.env` file.
(Don't do this if you have a redis server running already!)

You can run tests with:

    npm test

## Deploying

### Heroku Deploy

```sh
heroku create
heroku addons:create redistogo:nano  # Optional. Colu caches to Redis if available.
heroku addons:create airbrake:free-hrku  # error reporting, optional
git push heroku master
heroku ps:type hobby  # will be available 24/7, but costs $
```

### App configuration

Configuration is done through environment variables, described below:

```sh
HUBOT_SLACK_TOKEN           # your slack token, from Slack -> Integrations -> Hubot

# register for a Colu account at https://dashboard.colu.co/register
COLU_PRIVATE_SEED_WIF       # WIF = Wallet Info Format
COLU_NETWORK                # testnet or mainnet
COLU_MAINNET_APIKEY         # if on mainnet

FIREBASE_URL                # visit https://www.firebase.com/ to create DB
FIREBASE_SECRET             # found in the "Secrets" tab of your Firebase instance

KEENIO_PROJECT_ID           # keen.io analytics, optional
KEENIO_API_TOKEN            #

AIRBRAKE_API_KEY            # Airbrake error reporting, optional

APP_NAME                    # friendly app name for keen.io, airbrake, etc

NODE_ENV=production         # recommended settings for Node on Heroku
NODE_MODULES_CACHE=false    #
NPM_CONFIG_PRODUCTION=true  #

DEBUG=app                   # for verbose debugging info in logs

# Optionally, you may send a percentage of all awards back to your organization:
HOST_NAME                   # Friendly name
HOST_PERCENTAGE             # Percentage of awards to send to host (eg 3.5)
HOST_BTC_ADDRESS            # Bitcoin address of host
```

## License

MIT licensed.
