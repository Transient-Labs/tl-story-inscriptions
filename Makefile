# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# Clean the repo
clean:
	forge clean

# Remove modules
remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules

# Install the Modules
install:
	forge install foundry-rs/forge-std --no-commit
	forge install OpenZeppelin/openzeppelin-contracts@v5.0.1 --no-commit

# Update the modules
update: remove install

# Builds
build:
	forge clean && forge build --optimize --optimizer-runs 2000

# Tests
compiler_test:
	forge test --use 0.8.20
	forge test --use 0.8.21
	forge test --use 0.8.22

gas_test:
	forge test --fuzz-runs 10000 --gas-report