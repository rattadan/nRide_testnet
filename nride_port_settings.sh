#!/bin/sh

# Function to update the API and gRPC server addresses in app.toml
update_app_toml() {
  # Update API address
  current_api_address=$(grep -E '^\s*address\s*=' ~/.nridetestnet/config/app.toml | grep -m 1 "tcp" | cut -d '=' -f 2 | tr -d ' ')
  read -p "Current API address: $current_api_address - Do you want to change it? [y/N] " REPLY
  echo
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    read -p "Enter new API address (e.g., tcp://0.0.0.0:1317): " new_api_address
    echo
    sed -i "/^\[api\]/,/^\[/ { /^\s*address\s*=/ s|address = \".*\"|address = \"$new_api_address\"| }" ~/.nridetestnet/config/app.toml
  fi

  # Update gRPC address
  current_grpc_address=$(sed -n '/^\[grpc\]/,/\[/{ /address =/p }' ~/.nridetestnet/config/app.toml | cut -d '=' -f 2 | tr -d ' ')
  read -p "Current gRPC address: $current_grpc_address - Do you want to change it? [y/N] " REPLY
  echo
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    read -p "Enter new gRPC address (e.g., tcp://0.0.0.0:XXXX): " new_grpc_address
    echo
    sed -i "/^\[grpc\]/,/^\[/ { /^\s*address\s*=/ s|address = \".*\"|address = \"$new_grpc_address\"| }" ~/.nridetestnet/config/app.toml
  fi
}

# Function to update the chain ID in client.toml
update_client_toml() {
  current_chain_id=$(grep -E '^\s*chain-id\s*=' ~/.nridetestnet/config/client.toml | cut -d '=' -f 2 | tr -d ' ')
  read -p "Current chain ID: $current_chain_id - Do you want to change it? [y/N] " REPLY
  echo
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    read -p "Enter new chain ID: " new_chain_id
    echo
    sed -i "s|chain-id = \".*\"|chain-id = \"$new_chain_id\"|" ~/.nridetestnet/config/client.toml
  fi
}

# Function to update proxy_app and other addresses in config.toml
update_config_toml() {
  current_proxy_app=$(grep -E '^\s*proxy_app\s*=' ~/.nridetestnet/config/config.toml | cut -d '=' -f 2 | tr -d ' ')
  read -p "Current proxy app: $current_proxy_app - Do you want to change it? [y/N] " REPLY
  echo
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    read -p "Enter new proxy app address (e.g., tcp://127.0.0.1:XXXX): " new_proxy_app
    echo
    sed -i "s|proxy_app = \".*\"|proxy_app = \"$new_proxy_app\"|" ~/.nridetestnet/config/config.toml
  fi

  current_rpc_address=$(grep -E '^\s*caddr\s*=' ~/.nridetestnet/config/config.toml | cut -d '=' -f 2 | tr -d ' ')
  read -p "Current RPC address: $current_rpc_address - Do you want to change it? [y/N] " REPLY
  echo
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    read -p "Enter new RPC address (e.g., tcp://0.0.0.0:XXXX): " new_rpc_address
    echo
    sed -i "s|caddr = \".*\"|caddr = \"$new_rpc_address\"|" ~/.nridetestnet/config/config.toml
  fi

  current_laddr=$(grep -E '^\s*laddr\s*=' ~/.nridetestnet/config/config.toml | cut -d '=' -f 2 | tr -d ' ')
  read -p "Current laddr: $current_laddr - Do you want to change it? [y/N] " REPLY
  echo
  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    read -p "Enter new laddr (e.g., tcp://0.0.0.0:XXXX): " new_laddr
    echo
    sed -i "s|laddr = \".*\"|laddr = \"$new_laddr\"|" ~/.nridetestnet/config/config.toml
  fi
}

# Call the functions to update the files
update_app_toml
update_client_toml
update_config_toml