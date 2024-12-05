# nRide ICS Testnet Repository

- `git clone https://github.com/rattadan/nRide_testnet.git`   * Clone the Repository

## Local Images

- `make install`      *Builds the chain's binary*
- `make local-image`  *Builds the chain's docker image*
- `make testnet`     *Builds the testnet*
- `make sh-testnet`   *Build the local testnet*

## TestingSetting up the nRide Node (not necessary if you only want to opt-in))

please join the given Telegram Group, if you like to opt-in into our testnet
https://t.me/nride_official

- `nrided init <your_moniker> --chain-id nride-1`      *creates the config folder and initialises node binary*
- `nano .nrided/config/app.toml`      *head to your home folder and edit app.toml config file in hidden config directory*
- edit app.toml, change `minimum-gas-prices = "0stake"` to `minimum-gas-prices = "0unride"`
- 
If you run a Cosmos Testnet Validator node on the same machine:
- `nano .nrided/config/config.toml`      *check for RPC port allocation, to avoid port clashing*
- `proxy_app = "tcp://127.0.0.1:26658"` change to `proxy_app = "tcp://127.0.0.1:27658"`  also check if your firewall allows these connections
- under the [rpc] and [p2p] section change each
- `laddr = "tcp://127.0.0.1:26657"` change to `tcp://127.0.0.1:27657"`
- in client.toml change `node = "tcp://localhost:26657"`  to `node = "tcp://localhost:27657"` 

### Adding Seed to config.toml

To connect your node to the network, add the following seed to your `config.toml` file:

```
2ac32ef82e917cc2a6256521d09a38056de267e8@212.227.160.56:27656
```

### Opt in Before Launch

* You must submit your opt-in transaction before the spawn time is reached to start signing blocks as soon as the chain starts.

```
gaiad tx provider opt-in 115 --from wallet --chain-id provider --gas auto --gas-adjustment 2 --gas-prices 0.005uatom -y
```



## Further resources:
Game of Chains: First ICS Testnet playground
https://github.com/LavenderFive/game-of-chains-2022/blob/8b3d2c40b56a30a45e444d65bd9419ad7c0fe1a1/README.md

Interchain ICS repository:
https://cosmos.github.io/interchain-security/consumer-development/app-integration

Spawn Github:
https://rollchains.github.io/spawn/v0.50/

## Helpful Commands

Obtain nRide node ID:
- `nrided tendermint show-node-id`
- `nrided tendermint show-address`
- `nrided keys show wallet --bech val` (show your valoper address)

Inscribe your chain into the permissionless ICS module:
- `gaiad tx provider create-consumer create_consumer_tx.json --from wallet --chain-id provider --gas auto --gas-adjustment 2 --gas-prices 0.005uatom -y`

Query if your chain has been subscribed:
- `gaiad q provider list-consumer-chains` 
  (remember correct pagination, as the result shows only chain-id 1-99)

- `gaiad q provider consumer-chain 115`

A validator can opt in to a consumer chain by issuing the following message:

```
interchain-security-pd tx provider opt-in <consumer-id> <optional consumer-pub-key>
```

**Where:**
- `consumer-id` is the identifier of the consumer chain the validator wants to opt in to.
- `consumer-pub-key` corresponds to the public key the validator wants to use on the consumer chain, and it has the following format: `{"@type":"/cosmos.crypto.ed25519.PubKey","key":"<key>"}`.

**Note:**
- With my binary instance, there was an error, so you have to leave the pubkey away...

Example command:

```
gaiad tx provider opt-in 115 --from wallet --chain-id provider --gas auto --gas-adjustment 2 --gas-prices 0.005uatom -y
```

## nRide Genesis Configuration

This repository contains the configuration files and scripts for setting up the nRide blockchain network.

### Files

- **nride_fresh_genesis.json**: The main genesis file for the nRide blockchain wihtout CCTV states.
- **create.json**: Contains configuration parameters for creating a new consumer chain.
- **gaiad tx consumer create-consumer.sh**: Shell script for executing the consumer chain creation command.
- **checksums.txt**: Contains checksums for verifying the integrity of binaries and genesis files.
- **Seed.txt**: Contains seed information for the network.

### Setup Instructions

1. **Verify Checksums**
   - Ensure that the binaries and genesis files match the provided checksums in `checksums.txt`.


2. **Create Consumer Chain**
   - Use the `gaiad tx consumer create-consumer.sh` script to initialize the consumer chain.
   - Modify the parameters in `create.json` as needed.

3. **Genesis File n**
   -  `nride_fresh_genesis.json` 
### Important Parameters

- **Genesis Time**: Set in `nride_fresh_genesis.json` to specify the start time of the blockchain.
