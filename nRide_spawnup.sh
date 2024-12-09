#!/bin/bash
# Run this script to quickly install, setup, and run the current version of the network.
#
# Examples:
# CHAIN_ID="localchain-1" HOME_DIR="~/.nride" BLOCK_TIME="1000ms" CLEAN=true sh scripts/test_ics_node.sh
# CHAIN_ID="localchain-2" HOME_DIR="~/.nride" CLEAN=true RPC=36657 REST=2317 PROFF=6061 P2P=36656 GRPC=8090 GRPC_WEB=8091 ROSETTA=8081 BLOCK_TIME="500ms" sh scripts/test_ics_node.sh

# Initialize parameters with default values
CHAIN_ID=${CHAIN_ID:-"nride-1"}
MONIKER=${MONIKER:-"nRide Validator"}
KEYALGO=${KEYALGO:-"secp256k1"}
KEYRING=${KEYRING:-"test"}
HOME_DIR=$(eval echo "${HOME_DIR:-"~/.nride"}")
BINARY=${BINARY:-"nrided"}
DENOM=${DENOM:-"unride"}
CLEAN=${CLEAN:-"false"}
BLOCK_TIME=${BLOCK_TIME:-"1000ms"}
RPC=${RPC:-"26657"}
REST=${REST:-"1317"}
PROFF=${PROFF:-"6060"}
P2P=${P2P:-"26656"}
GRPC=${GRPC:-"9090"}
GRPC_WEB=${GRPC_WEB:-"9091"}
ROSETTA=${ROSETTA:-"8080"}
GENESIS_KEY_NAME=${GENESIS_KEY_NAME:-"genesis-key"}
GENESIS_AMOUNT=${GENESIS_AMOUNT:-"100000000unride"}
METADATA_NAME=${METADATA_NAME:-"nRide ICS Testnet"}
METADATA_DESCRIPTION=${METADATA_DESCRIPTION:-"nRide ICS Testnet"}

set -eu

export KEY="wallet"

# Function to display the menu
show_menu() {
  echo "\nCurrent Configuration:"
  echo "1. CHAIN_ID = $CHAIN_ID"
  echo "2. MONIKER = $MONIKER"
  echo "3. KEYALGO = $KEYALGO"
  echo "4. KEYRING = $KEYRING"
  echo "5. HOME_DIR = $HOME_DIR"
  echo "6. BINARY = $BINARY"
  echo "7. DENOM = $DENOM"
  echo "8. CLEAN = $CLEAN"
  echo "9. BLOCK_TIME = $BLOCK_TIME"
  echo "10. RPC = $RPC"
  echo "11. REST = $REST"
  echo "12. PROFF = $PROFF"
  echo "13. P2P = $P2P"
  echo "14. GRPC = $GRPC"
  echo "15. GRPC_WEB = $GRPC_WEB"
  echo "16. ROSETTA = $ROSETTA"
  echo "17. Run Script"
  echo "18. Exit without saving"
  echo "19. Genesis Key Name = $GENESIS_KEY_NAME"
  echo "20. Genesis Amount = $GENESIS_AMOUNT"
  echo "21. Metadata Name = $METADATA_NAME"
  echo "22. Metadata Description = $METADATA_DESCRIPTION"
  echo "Choose a parameter to edit or an action (1-22):"
}

# Function to update a parameter
update_parameter() {
  case $1 in
    1) read -p "Enter new CHAIN_ID: " CHAIN_ID ;;
    2) read -p "Enter new MONIKER: " MONIKER ;;
    3) read -p "Enter new KEYALGO: " KEYALGO ;;
    4) read -p "Enter new KEYRING: " KEYRING ;;
    5) read -p "Enter new HOME_DIR: " HOME_DIR ;;
    6) read -p "Enter new BINARY: " BINARY ;;
    7) read -p "Enter new DENOM: " DENOM ;;
    8) read -p "Enter new CLEAN (true/false): " CLEAN ;;
    9) read -p "Enter new BLOCK_TIME: " BLOCK_TIME ;;
    10) read -p "Enter new RPC: " RPC ;;
    11) read -p "Enter new REST: " REST ;;
    12) read -p "Enter new PROFF: " PROFF ;;
    13) read -p "Enter new P2P: " P2P ;;
    14) read -p "Enter new GRPC: " GRPC ;;
    15) read -p "Enter new GRPC_WEB: " GRPC_WEB ;;
    16) read -p "Enter new ROSETTA: " ROSETTA ;;
    17) run_script ;;
    18) exit 0 ;;
    19) read -p "Enter new Genesis Key Name (the wallet you created): " GENESIS_KEY_NAME ;;
    20) read -p "Enter new Genesis Amount: " GENESIS_AMOUNT ;;
    21) read -p "Enter new Metadata Name: " METADATA_NAME ;;
    22) read -p "Enter new Metadata Description: " METADATA_DESCRIPTION ;;
    *) echo "Invalid option" ;;
  esac
}

# Function to calculate and display SHA256 checksums
show_checksums() {
  echo "\nCalculating SHA256 checksums..."
  genesis_checksum=$(sha256sum $HOME_DIR/config/genesis.json | awk '{ print $1 }')
  binary_checksum=$(sha256sum /go/bin/$BINARY | awk '{ print $1 }')
  echo "Genesis JSON Checksum: $genesis_checksum"
  echo "Binary Checksum: $binary_checksum"
  echo "Press any key to return to the main menu..."
  read -n 1 -s
}

# Function to create JSON file with checksums and other information
create_json_file() {
  # Calculate spawn time 5 days from now
  spawn_time=$(date -u -d "+5 days" +%Y-%m-%dT%H:%M:%S.%6NZ)
  cat <<EOF > create_ICS_Consumer_Chain.json
{
  "chain_id": "$CHAIN_ID",
  "metadata": {
    "name": "$METADATA_NAME",
    "description": "$METADATA_DESCRIPTION",
    "metadata": "no metadata"
  },
  "initialization_parameters": {
    "initial_height": {
      "revision_number": 1,
      "revision_height": 1
    },
    "genesis_hash": "$genesis_checksum",
    "binary_hash": "$binary_checksum",
    "spawn_time": "$spawn_time",
    "unbonding_period": 1728000000000000,
    "ccv_timeout_period": 2419200000000000,
    "transfer_timeout_period": 1800000000000,
    "consumer_redistribution_fraction": "0.50",
    "blocks_per_distribution_transmission": 1000,
    "historical_entries": 10000
  },
  "power_shaping_params": {
    "top_N": 0,
    "validators_power_cap": 20,
    "validator_set_cap": 40,
    "allowlist": [],
    "denylist": [],
    "min_stake": "0",
    "allow_inactive_vals": false
  }
}
EOF
  echo "JSON file 'create_ICS_Consumer_Chain.json' created successfully."
}

# Function to run the main script logic
run_script() {
  echo "Running the script with the current configuration..."
  config_toml="${HOME_DIR}/config/config.toml"
  client_toml="${HOME_DIR}/config/client.toml"
  app_toml="${HOME_DIR}/config/app.toml"
  genesis_json="${HOME_DIR}/config/genesis.json"

  # if which binary does not exist, install it
  if [ -z `which $BINARY` ]; then
    make install

    if [ -z `which $BINARY` ]; then
      echo "Ensure $BINARY is installed and in your PATH"
      exit 1
    fi
  fi

  command -v $BINARY > /dev/null 2>&1 || { echo >&2 "$BINARY command not found. Ensure this is setup / properly installed in your GOPATH (make install)."; exit 1; }
  command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

  set_config() {
    $BINARY config set client chain-id $CHAIN_ID
    $BINARY config set client keyring-backend $KEYRING
  }
  set_config

  from_scratch () {
    # Fresh install on current branch
    make install

    # remove existing daemon files.
    if [ ${#HOME_DIR} -le 2 ]; then
      echo "HOME_DIR must be more than 2 characters long"
      return
    fi
    rm -rf $HOME_DIR && echo "Removed $HOME_DIR"

    # reset values if not set already after whipe
    set_config

    $BINARY init $CHAIN_ID --chain-id $CHAIN_ID --overwrite --default-denom $DENOM --home $HOME_DIR

    update_test_genesis () {
      cat $HOME_DIR/config/genesis.json | jq "$1" > $HOME_DIR/config/tmp_genesis.json && mv $HOME_DIR/config/tmp_genesis.json $HOME_DIR/config/genesis.json
    }

    $BINARY keys list --keyring-backend $KEYRING --home $HOME_DIR

    # Allocate genesis accounts
    echo "Adding genesis account..."
    $BINARY add-genesis-account $GENESIS_KEY_NAME $GENESIS_AMOUNT --home $HOME_DIR
    show_checksums
    create_json_file

    # ICS provider genesis hack
    HACK_DIR=icshack-1 && echo $HACK_DIR
    rm -rf $HACK_DIR
    cp -r ${HOME_DIR} $HACK_DIR

    $BINARY add-consumer-section provider --home $HACK_DIR
    ccvjson=`jq '.app_state["ccvconsumer"]' $HACK_DIR/config/genesis.json`
    echo $ccvjson
    jq '.app_state["ccvconsumer"] = '"$ccvjson"  ${HACK_DIR}/config/genesis.json > json.tmp && mv json.tmp $genesis_json
    rm -rf $HACK_DIR

    update_test_genesis `printf '.app_state["ccvconsumer"]["params"]["unbonding_period"]="%s"' "240s"`

    # Validate the genesis file
    echo "Validating genesis file..."
    validation_output=$($BINARY genesis validate --home $HOME_DIR 2>&1)
    if [ $? -eq 0 ]; then
      echo "Genesis validation successful."
    else
      echo "Genesis validation failed:"
      echo "$validation_output"
    fi
  }

  # check if CLEAN is not set to false
  if [ "$CLEAN" != "false" ]; then
    echo "Starting from a clean state"
    from_scratch
  fi

  # Opens the RPC endpoint to outside connections
  sed -i -e 's/laddr = "tcp:\/\/127.0.0.1:26657"/c\laddr = "tcp:\/\/0.0.0.0:'$RPC'"/g' $HOME_DIR/config/config.toml
  sed -i -e 's/cors_allowed_origins = \[\]/cors_allowed_origins = \["\*"\]/g' $HOME_DIR/config/config.toml

  # REST endpoint
  sed -i -e 's/address = "tcp:\/\/localhost:1317"/address = "tcp:\/\/0.0.0.0:'$REST'"/g' $HOME_DIR/config/app.toml
  sed -i -e 's/enable = false/enable = true/g' $HOME_DIR/config/app.toml

  # peer exchange
  sed -i -e 's/pprof_laddr = "localhost:6060"/pprof_laddr = "localhost:'$PROFF'"/g' $HOME_DIR/config/config.toml
  sed -i -e 's/laddr = "tcp:\/\/0.0.0.0:26656"/laddr = "tcp:\/\/0.0.0.0:'$P2P'"/g' $HOME_DIR/config/config.toml

  # GRPC
  sed -i -e 's/address = "localhost:9090"/address = "0.0.0.0:'$GRPC'"/g' $HOME_DIR/config/app.toml
  sed -i -e 's/address = "localhost:9091"/address = "0.0.0.0:'$GRPC_WEB'"/g' $HOME_DIR/config/app.toml

  # Rosetta Api
  sed -i -e 's/address = ":8080"/address = "0.0.0.0:'$ROSETTA'"/g' $HOME_DIR/config/app.toml

  # Faster blocks
  sed -i -e 's/timeout_commit = "5s"/timeout_commit = "'$BLOCK_TIME'"/g' $HOME_DIR/config/config.toml

  # Start the daemon in the background
  $BINARY start --pruning=nothing  --minimum-gas-prices=0$DENOM --rpc.laddr="tcp://0.0.0.0:$RPC" --home $HOME_DIR
}

# Main loop
while true; do
  show_menu
  read -p "Select an option: " choice
  update_parameter $choice
done
