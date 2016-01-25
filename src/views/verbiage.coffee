class Verbiage

  @NEW_BTC = "
    If you don't have a Bitcoin address,
    we recommend creating one at https://www.coinbase.com --
    note that you do *not* need to add money to the wallet to receive coins.
    "

  @NEW_BTC_AND_WHY = "
    If you enter a Bitcoin address, others will be able to send you
    *project coins* at that address. #{@NEW_BTC}
    "

module.exports = Verbiage
