# nRide ICS Testnet Repository

This repo describes the process of launching an ICS chain on the provider CosmosHUB Testnet.

[nRide Website](https://7052pdsgs5a8he1mmine0osg4s.ingress.akash-palmito.org/?cat=1)

# Phases of Launch

There are several phases of the nRide ICS Chain launch:
1. Build the binaries using the spawn-cli  
2. Create a pre-spawn `genesis.json` file
3. TX a consumer-chain create message in the Security-Providing Network
4. After spawn time is reached, copy the Crosschain-Validation state into the Consumer Node
5. Start the Consumer Node

**Note**: If you start your node before spawn time has reached and no CCV state is imported, you will get an error that your network does not reach the "default-Power-reduction".

Although you can create Validators in the Genesis file, this set is not necessary for the consensus engine. The Validator Set in an ICS chain serves as a blockchain history database and RPC/gRPC nodes and as a Token distribution service to Stakers. Rewards will be distributed to the underlying ATOM Validators resp. their stakers and the network stakers on a 50:50 ratio. So with opting-in as a CosmosHUB mainnet Validator, you will generate rewards for your Stakers and your own Commission Share.

### Opt in as Cosmos Validator
If you already run a Cosmos Validator in the active Set, for opting-in only, there is only one command necessary:

* You must submit your opt-in transaction before the spawn time is reached to start signing blocks as soon as the chain starts.

```
gaiad tx provider opt-in 115 --from wallet --chain-id provider --gas auto --gas-adjustment 2 --gas-prices 0.005uatom -y
```

Check if your subscription worked:

```
gaiad q provider consumer-opted-in-validators 115
```

while 115 is the consumer-chain-id.

As an opted-in Validator, you and all your stakers will earn network rewards from the nRide network.

## Run a local nRide Node on your machine

If you want to run a nRide Node on your machine too, you will need to install the "nrided" binary: 

- `git clone https://github.com/rattadan/nRide_testnet.git`   * Clone the Repository

- `make install`

copy the genesis_after_spawn.json into your config folder and start your nRide Node



# Setting up the nRide Node (not necessary if you only want to opt-in...)

please join the given Telegram Group, if you like to opt-in into our testnet
https://t.me/nride_official

- `nrided init <your_moniker> --chain-id nride-1`      *creates the config folder and initialises node binary*
- `nano .nrided/config/app.toml`      *head to your home folder and edit app.toml config file in hidden config directory*
- edit app.toml, change `minimum-gas-prices = "0stake"` to `minimum-gas-prices = "0unride"`
- 
Only necessary if you run a Cosmos Testnet Validator node on the same machine:
- `nano .nrided/config/config.toml`      *check for RPC port allocation, to avoid port clashing*
- `proxy_app = "tcp://127.0.0.1:26658"` change to `proxy_app = "tcp://127.0.0.1:27658"`  also check if your firewall allows these connections
- under the [rpc] and [p2p] section change each
- `laddr = "tcp://127.0.0.1:26657"` change to `tcp://127.0.0.1:27657"`
- in client.toml change `node = "tcp://localhost:26657"`  to `node = "tcp://localhost:27657"` 

### Adding Seed to config.toml

To connect your node to the network, add the following seed to your `config.toml` file:

```
[SEED]
2ac32ef82e917cc2a6256521d09a38056de267e8@212.227.160.56:27656
```


Chain Startup:

After the spawn time has passed, you migrate the CCV state from the underlying provider chain into your ICS chain:

Collect the Cross-Chain Validation (CCV) state from the provider chain.

`gaiad q provider consumer-genesis <consumer-id> -o json > ccv-state.json`

Update the CCV state with the reward denoms.
`jq '.params.reward_denoms |= ["<your chain denom>"]' ccv-state.json > ccv-denom.json`
`jq '.params.provider_reward_denoms |= ["uatom"]' ccv-denom.json > ccv-provider-denom.json`
Update the genesis file with the CCV state
`jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' <consumer genesis without CCV state> ccv-provider-denom.json > <consumer genesis file with CCV state>`

### Explanation of Commands

The commands you provided are using `jq`, a lightweight and flexible command-line JSON processor, to manipulate JSON files. Here's what each command does:

#### First Command:

```bash
jq '.params.reward_denoms |= ["<your chain denom>"]' ccv-state.json > ccv-denom.json
```
This command takes the `ccv-state.json` file and updates the `reward_denoms` field within the `params` object to be a list containing `"<your chain denom>"`. The result is then saved to a new file called `ccv-denom.json`.

#### Second Command:

```bash
jq '.params.provider_reward_denoms |= ["uatom"]' ccv-denom.json > ccv-provider-denom.json
```
This command takes the `ccv-denom.json` file and updates the `provider_reward_denoms` field within the `params` object to be a list containing `"uatom"`. The result is saved to a new file called `ccv-provider-denom.json`.

#### Third Command:

```bash
jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' <consumer genesis without CCV state> ccv-provider-denom.json > <consumer genesis file with CCV state>
```
This command uses the `-s` option of `jq`, which reads all inputs into an array. It takes two JSON files: a consumer genesis file without CCV state and `ccv-provider-denom.json`. It assigns the content of `ccv-provider-denom.json` to the `ccvconsumer` field within the `app_state` object of the first file. The modified genesis file is then saved to a new file, which is the consumer genesis file with the CCV state added.

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
interchain-security-pd tx provider opt-in <consumer-id>
```
Consumer ID for Testnet = 115

**Where:**
- `consumer-id` is the identifier of the consumer chain the validator wants to opt in to.
- `consumer-pub-key` corresponds to the public key the validator wants to use on the consumer chain, and it has the following format: `{"@type":"/cosmos.crypto.ed25519.PubKey","key":"<key>"}`.

**Note:**
- With my binary instance, there was an error, so you have to leave the pubkey away...


```
gaiad tx provider opt-in 115 --from wallet --chain-id provider --gas auto --gas-adjustment 2 --gas-prices 0.005uatom -y
```

## nRide Genesis Configuration

This repository contains the configuration files and scripts for setting up the nRide blockchain network.

### Files

- **nride_fresh_genesis.json**: The main genesis file for the nRide blockchain without CCTV states.
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

   Notice: You don't need to add a mandatory Validator Information directly into the genesis file, because the ICS consensus module is being linked with the underlying Cosmos Validator Set, not the staking Validator set.

### Important Parameters

- **Genesis Time**: Set in `nride_fresh_genesis.json` to specify the start time of the blockchain.





Create a Validator on Provider Testnet:

according to # Gaia v21.0.0 Release Notes 

❗***You must use Golang v1.22 if building from source.***

took me a few days to learn that v1.23.4 compiled without errors, but the binary showed off errors later

```bash
git clone https://github.com/cosmos/gaia
cd gaia && git checkout v21.0.0
make install
```

..after you compiled the binary:


gaiad init "Your Label Here" --chain-id provider
cd .gaia/config
nano app.toml
minimum-gas-prices = "0.025uatom" 

sync your node using this guide from nodestake
https://nodestake.org/cosmos
set seed, peers and download snapshsot
lets sync: gaiad start 

create a wallet
gaiad keys add wallet
or recover an existing one
gaiad keys add wallet --recover
gaiad keys list

get some testnet atoms on your wallet (ask in discord or tg)


gaiad tx staking create-validator create_validator_gaia.json --from wallet --gas auto --gas-adjustment 2 --gas-prices 0.005uatom

with
create_validator_gaia.json 
  {
	"pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"BcCDlvRODsZCYNi82PJA4h9Xe0+nht6EU5mXOQlmLyE="},
	"amount": "100uatom",
	"moniker": "nRide Validator",
	"identity": "166879CD027B2772",
	"website": "www.nride.com",
	"security": "info@nride.com",
	"details": "nRide.com ICS Testnet Validation Node",
	"commission-rate": "0.1",
	"commission-max-rate": "0.2",
	"commission-max-change-rate": "0.01"
}

replace pubkey above value with your own values:
gaiad tendermint show-validator

Check if your Validator is somewhere (look in the inactive list)
Delegate some Tokens to your Validator


## Further resources:
Game of Chains: First ICS Testnet playground
https://github.com/LavenderFive/game-of-chains-2022/blob/8b3d2c40b56a30a45e444d65bd9419ad7c0fe1a1/README.md

Nodestake Testnet Snapshot, Seeds & Peers
https://nodestake.org/cosmos

Interchain ICS repository:
https://cosmos.github.io/interchain-security/consumer-development/app-integration

Spawn Github:
https://rollchains.github.io/spawn/v0.50/
