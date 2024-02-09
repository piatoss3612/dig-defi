## Hyperlane V3

### Install package

```shell
$ forge install hyperlane-xyz/hyperlane-monorepo@main
$ forge install OpenZeppelin/openzeppelin-contracts
$ forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

### Remapping

```shell
$ forge remappings > remappings.txt
```

```txt
# remappings.txt
@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
ds-test/=lib/forge-std/lib/ds-test/src/
erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/
forge-std/=lib/forge-std/src/
@hyperlane/=lib/hyperlane-monorepo/solidity/
openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/
openzeppelin-contracts/=lib/openzeppelin-contracts/
```

### foundry.toml

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

# See more config options https://github.com/foundry-rs/foundry/blob/master/crates/config/README.md#all-options
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
mumbai = "${MUMBAI_RPC_URL}"

[etherscan]
sepolia = { key = "${SEPOLIA_ETHERSCAN_API_KEY}" }
mumbai = { key = "${POLYGONSCAN_API_KEY}", url = "https://api-testnet.polygonscan.com/api" }
```

### .env

```shell
MUMBAI_RPC_URL=https://polygon-mumbai.g.alchemy.com/v2/<API_KEY>
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/<API_KEY>

PRIVATE_KEY=<YOUR_PRIVATE_KEY>

SEPOLIA_ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>
POLYGONSCAN_API_KEY=<YOUR_POLYGONSCAN_API_KEY>
```

### Deploy

- Deploy and Verify VoteMain on Sepolia

```shell
$ forge script script/VoteMain.s.sol:DeployScript --rpc-url sepolia --broadcast --verify -vvvv
...
== Logs ==
  VoteMain created at address:  0xC5FdAfa7D8aD01156852e3E6403459358C21EA62
```

- Deploy VoteRouter on Mumbai

```shell
$ forge script script/VoteRouter.s.sol:DeployScript --rpc-url mumbai --broadcast --verify -vvvv
...
== Logs ==
  VoteRouter created at address:  0x1490c98b64Dc2a5963B2648a195ACE9719225d5D
```

### Create a new proposal on VoteMain

```shell
$ forge script script/VoteMain.s.sol:CreateProposalScript --rpc-url sepolia --broadcast -vvvv
...
== Logs ==
  Proposal created with ID:  106343027174924039072363677969788076485983697713036371895217183766366697150692
```

### Vote on a proposal on VoteRouter

```shell
$ forge script script/VoteRouter.s.sol:VoteScript --rpc-url mumbai --broadcast -vvvv
```

### Check on explorer

- [Hyperlane V3 Explorer](https://explorer.hyperlane.xyz/message/0x3dd2cc288f9475e7c9210986164b93efb6a0e335314e492f81460c9662008ebf)

### Check on Sepolia

```shell
$ forge script script/VoteMain.s.sol:CheckProposalScript --rpc-url sepolia -vvvv
...
== Logs ==
  Votes against:  1
```

## Cross-Chain NFT

### Deploy NFT Router to Sepolia and Verify 

```shell
$ forge script script/CrosschainNftRouter.s.sol:Deploy --rpc-url sepolia --broadcast --verify -vvvv
...
== Logs ==
  Deployed CrosschainNftRouter at:  0xE06F728cB5fD5a45BA12a7528e5f90d4641B85EF
```

### Deploy NFT to Mumbai and Verify

```shell
$ forge script script/CrosschainNftMumbai.s.sol:Deploy --rpc-url mumbai --broadcast --verify -vvvv
...
== Logs ==
  Deployed CrosschainNft at:  0x4a1A6865A5bb6C9ed988052e6f004c81c9D424Eb
```

### Send NFT from Sepolia to Mumbai

```shell
$ forge script script/CrosschainNftRouter.s.sol:SendNft --rpc-url sepolia --broadcast -vvvv
...
== Logs ==
  Sent NFT to domain:  80001
```

### Check Hyperlane V3 Explorer

- [Hyperlane V3 Explorer](https://explorer.hyperlane.xyz/message/0x95cda4dc1307ad3e9b6a886cc76162a0a79e89bca8543ae0df3537cd15b1b903)

### Check token URI on Mumbai

```shell
$ forge script script/CrosschainNftMumbai.s.sol:CheckURI --rpc-url mumbai -vvvv
...
== Logs ==
  NFT URI:  https://green-main-hoverfly-930.mypinata.cloud/ipfs/QmXbFt5tDifdSgPmhFrwD56iNsJqbxCZ8dSdv4qzp49PNs
```

## References

- [Messaging API -V3](https://blog.hyperlaneindia.xyz/messaging-api-v3)