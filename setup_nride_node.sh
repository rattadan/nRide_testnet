#!/bin/sh



  # Update minimum-gas-prices
  echo "minimum-gas-prices = \"0.25unride\"" >> ~/.nride/config/app.toml

  # Update chain-id in client.toml
  echo "chain-id = \"nride_testnet-1\"" > ~/.nride/config/client.toml
