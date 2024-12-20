#!/bin/sh

  read -p "Enter your moniker: " Moniker
  gaiad init $Moniker --chain-id provider

  # Update minimum-gas-prices
  echo "minimum-gas-prices = \"0.25uatom\"" >> ~/.gaia/config/app.toml

  # Update chain-id in client.toml
  echo "chain-id = \"provider\"" > ~/.gaia/config/client.toml

  #retrieve Chain state from Nodestake
  curl -Ls https://ss-rs.cosmos.nodestake.org/addrbook.json > $HOME/.gaia/config/addrbook.json 
  curl -Ls https://ss-rs.cosmos.nodestake.org/genesis.json > $HOME/.gaia/config/genesis.json 
  SNAP_NAME=$(curl -s https://ss-rs.cosmos.nodestake.org/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
  curl -o - -L https://ss-rs.cosmos.nodestake.org/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.gaia


