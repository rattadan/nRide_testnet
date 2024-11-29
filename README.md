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
- `nrided init <your_moniker> --chain-id nride-1`      *create folder and init node*
- `nano .nrided/config/app.toml`      *head to your home folder and edit app.toml config file in hidden config directory*


## Webapp Template

Generate the template base with spawn. Requires [npm](https://nodejs.org/en/download/package-manager) and [yarn](https://classic.yarnpkg.com/lang/en/docs/install) to be installed.

- `make generate-webapp` *[Cosmology Webapp Template](https://github.com/cosmology-tech/create-cosmos-app)*

Start the testnet with `make testnet`, and open the webapp `cd ./web && yarn dev`

