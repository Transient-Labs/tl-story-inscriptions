# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# Clean the repo
clean:
	forge clean

# Remove modules
remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install:
	forge install foundry-rs/forge-std
	forge install OpenZeppelin/openzeppelin-contracts@v4.8.3
	forge install OpenZeppelin/openzeppelin-contracts-upgradeable@v4.8.3

# Update the modules
update: remove install

# Builds
build:
	forge clean && forge build --optimize --optimizer-runs 2000

# Tests
test_suite:
	forge test --use 0.8.17
	forge test --use 0.8.18
	forge test --use 0.8.19
	forge test --use 0.8.20
