#!/bin/bash

# Path to the genesis file
GENESIS_FILE="$HOME/.nridetestnet/config/genesis_pre_spawn.json"

# Retrieve the genesis time from the genesis file
GENESIS_TIME=$(jq -r '.genesis_time' "$GENESIS_FILE")

# Convert the genesis time to seconds since epoch
GENESIS_EPOCH=$(date -d "$GENESIS_TIME" +%s)

# Calculate the spawn time (6 hours before genesis time)
SPAWN_EPOCH=$(($GENESIS_EPOCH + 21600))
SPAWN_TIME=$(date -d "@$SPAWN_EPOCH" -Iseconds)

# Retrieve the sa256checksums from nride_fresh_genesis.json
GENESIS_HASH=$(sha256sum "$GENESIS_FILE" | awk '{ print $1 }')

# Retrieve the Go binary path
GOPATH=$(go env GOPATH)
# Path to the binary file
BINARY="$GOPATH/bin/nrided"

# Retrieve the binary hash from the binary file
BINARY_HASH=$(sha256sum "$BINARY" | awk '{ print $1 }')

# Expected chain_id
EXPECTED_CHAIN_ID="nride-testnet-1"

# Retrieve the chain_id from the genesis file
CHAIN_ID=$(jq -r '.chain_id' "$GENESIS_FILE")

# Check if the chain_id matches the expected value
if [ "$CHAIN_ID" = "$EXPECTED_CHAIN_ID" ]; then
    echo "Chain ID matches: $CHAIN_ID"
else
    echo "Chain ID mismatch: expected $EXPECTED_CHAIN_ID, but got $CHAIN_ID"
    exit 1
fi

# Create the JSON structure
OUTPUT_JSON=$(jq -n \
    --arg chain_id "$CHAIN_ID" \
    --arg spawn_time "$SPAWN_TIME" \
    --arg genesis_hash "$GENESIS_HASH" \
    --arg binary_hash "$BINARY_HASH" \
    '{
        chain_id: $chain_id,
        metadata: {
            name: "nRide ICS Testnet",
            description: "nRide is developing a peer-to-peer ride-hailing protocol that connects riders and drivers directly, eliminating intermediaries. By removing middlemen, nRide aims to reduce fees and increase transparency, while also creating a more equitable platform for drivers and riders. Additionally, nRide solves the problem of isolated user bases by providing a standardized way for ride-hailing applications to connect with each other and access a larger user base, fostering a more open and competitive marketplace",
            metadata: "{\"forge_json_url\":\"https://raw.githubusercontent.com/nride/nride-sc/refs/heads/main/assets/nRide.json\",\"stage\":\"pre-launch\"}"
        },
        initialization_parameters: {
            initial_height: {
                revision_number: 1,
                revision_height: 1
            },
            genesis_hash: $genesis_hash,
            binary_hash: $binary_hash,
            spawn_time: $spawn_time,
            unbonding_period: 1728000000000000,
            ccv_timeout_period: 2419200000000000,
            transfer_timeout_period: 1800000000000,
            consumer_redistribution_fraction: "0.50",
            blocks_per_distribution_transmission: 1000,
            historical_entries: 10000
        },
"power_shaping_parameters": {
    "top_N": 0,
    "validators_power_cap": 80,
    "validator_set_cap": 40,
    "allowlist": [],
    "denylist": [],
    "min_stake": 0,
    "allow_inactive_vals": true
  }
    }')

# Write the generated JSON to create_ICS_Subscription.json
echo "$OUTPUT_JSON" > $HOME/.gaia/config/created_ICS_Subscription.json

echo "Update completed successfully! Spawn time set to: $SPAWN_TIME"
