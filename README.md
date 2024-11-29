# nRide ICS Testnet Repository

- `git clone https://github.com/rattadan/nRide_testnet.git`   * Clone the Repository

## Local Images

- `make install`      *Builds the chain's binary*
- `make local-image`  *Builds the chain's docker image*
- `make testnet`     *Builds the testnet*
- `make sh-testnet`   *Build the local testnet*
## Testing

please join the given Telegram Group, if you like to opt-in into our testnet
https://t.me/nride_official
- `nrided init <your_moniker> --chain-id nride-1`      *creates the config folder and initialises node binary*
- `nano .nrided/config/app.toml`      *head to your home folder and edit app.toml config file in hidden config directory*
- edit app.toml, change `minimum-gas-prices = "0stake"` to `minimum-gas-prices = "0unride"`
- 
If you run a cosmos testnet Validator node on the same machine:
- `nano .nrided/config/config.toml`      *check for RPC port allocation, to avoid port clashing*
- `proxy_app = "tcp://127.0.0.1:26658"` change to `proxy_app = "tcp://127.0.0.1:27658"`  also check if your firewall allows these connections
- under the [rpc] and [p2p] section change each
- `laddr = "tcp://127.0.0.1:26657"` change to `tcp://127.0.0.1:27657"`

## Further ressources:
Game of Chains: First ICS Testnet playground
https://github.com/LavenderFive/game-of-chains-2022/blob/8b3d2c40b56a30a45e444d65bd9419ad7c0fe1a1/README.md

Interchain ICS repository:
https://cosmos.github.io/interchain-security/consumer-development/app-integration

Spawn Github:
https://rollchains.github.io/spawn/v0.50/



## Webapp Template

Generate the template base with spawn. Requires [npm](https://nodejs.org/en/download/package-manager) and [yarn](https://classic.yarnpkg.com/lang/en/docs/install) to be installed.

- `make generate-webapp` *[Cosmology Webapp Template](https://github.com/cosmology-tech/create-cosmos-app)*

Start the testnet with `make testnet`, and open the webapp `cd ./web && yarn dev`

