## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

## Hello World Example

### Deploy

```shell
$ source .env
$ forge script script/DeployCrossChainHelloWorldMumbai.s.sol:CrossChainHelloWorldMumbaiScript --rpc-url mumbai --broadcast -vvvv
$ forge script script/DeployCrossChainHelloWorldSepolia.s.sol:CrossChainHelloWorldSepoliaScript --rpc-url sepolia --broadcast -vvvv
```

### Verify Contract

```shell
$ forge verify-contract 0x1e5501bf7a4821bE9251Aa617560c03f481A39bd --chain mumbai --constructor-args $(cast abi-encode "constructor(address)" 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8) src/CrossChainHelloWorld.sol:CrossChainHelloWorld
```
```shell
$ forge verify-contract 0xe9b53942eadEeE83EB998554C042955B248bb30A --chain sepolia --constructor-args $(cast abi-encode "constructor(address)" 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1) src/CrossChainHelloWorld.sol:CrossChainHelloWorld
```

> 환경 변수에 `ETHERSCAN_API_KEY`를 설정하게 되면 다른 체인에서도 이 값을 가져다 쓰므로 여러 개의 체인을 사용할 때는 이름을 구분할 수 있도록 설정해야 한다.

### Script

- set trust address of each contract on each chain

```shell
$ forge script script/TrustAddressCrossChainHelloWorldMumbai.s.sol:SetTrustAddressMumbaiScript --rpc-url mumbai --broadcast -vvvv
$ forge script script/TrustAddressCrossChainHelloWorldSepolia.s.sol:SetTrustAddressSepoliaScript --rpc-url sepolia --broadcast -vvvv
```

- check data before sending message

```shell
$ forge script script/CheckDataMumbai.sol --rpc-url mumbai -vvvv
...
== Logs ==
  data:  Nothing received yet
```

- send message from Sepolia to Mumbai

```shell
$ forge script script/SendMessageCrossChainHelloWorldSepolia.s.sol --rpc-url sepolia -vvvv
```

- check data after sending message

> it takes for a while to get the result.

```shell
$ forge script script/CheckDataMumbai.sol --rpc-url mumbai -vvvv
...
== Logs ==
  data:  Hello World from Sepolia
```

## Swap MATIC to ETH

### Deploy

```shell
$ forge script script/LayerZeroV1SwapMumbai.s.sol:DeployScript --rpc-url mumbai --broadcast -vvvv
$ forge script script/LayerZeroV1SwapSepolia.s.sol:DeployScript --rpc-url sepolia --broadcast -vvvv
```

### Verify Contract

```shell
$ forge verify-contract 0xc76a9033e2B46c8305417A0f065C9f77b5D04fAb --chain mumbai --constructor-args $(cast abi-encode "constructor(address)" 0xf69186dfBa60DdB133E91E9A4B5673624293d8F8) src/LayerZeroV1Swap.sol:LayerZeroV1Swap
$ forge verify-contract 0x4e15C6Ba57e4bFaF200867F84Bdd7E6bb77EaC39 --chain sepolia --constructor-args $(cast abi-encode "constructor(address)" 0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1) src/LayerZeroV1Swap.sol:LayerZeroV1Swap
```

### Script

- set trust address of each contract on each chain
- send 1 ETH to contract on Sepolia

```shell
$ forge script script/LayerZeroV1SwapMumbai.s.sol:SetupScript --rpc-url mumbai --broadcast -vvvv
$ forge script script/LayerZeroV1SwapSepolia.s.sol:SetupScript --rpc-url sepolia --broadcast -vvvv
```

- check balance of contract and receiver on Sepolia (ETH) before swap

```shell
$ forge script script/LayerZeroV1SwapSepolia.s.sol:CheckBalanceScript --rpc-url sepolia -vvvv
...
== Logs ==
  Contract Balance:  1000000000000000000
  Receiver Balance:  0
```

- check balance of contract and sender on Mumbai (MATIC) before swap

```shell
$ forge script script/LayerZeroV1SwapMumbai.s.sol:CheckBalanceScript --rpc-url mumbai -vvvv
...
== Logs ==
  Contract Balance:  0
  Sender Balance:  6099462406402710823
```

- estimate gas for swap 1 MATIC to 1 ETH on Layer Zero

```shell
$ forge script script/LayerZeroV1SwapMumbai.s.sol:EstimateGasScript --rpc-url mumbai -vvvv
...
== Logs ==
  Estimated gas:  66686331023106700455
```

- swap 1 MATIC to 1 ETH

```shell
$ forge script script/LayerZeroV1SwapMumbai.s.sol:SwapScript --rpc-url mumbai --broadcast -vvvv
```

> actually, estimated gas is over 50 ETH, so it fails. Why is it so expensive?

- withdraw remaining balance of contract on Sepolia

```shell
$ forge script script/LayerZeroV1SwapSepolia.s.sol:WithdrawScript --rpc-url sepolia --broadcast -vvvv
```


## References

- [Klaytn에서 LayerZero 크로스체인 메시지 전송하는 방법](https://medium.com/klaytn-kr/klaytn%EC%97%90%EC%84%9C-layerzero-%ED%81%AC%EB%A1%9C%EC%8A%A4%EC%B2%B4%EC%9D%B8-%EB%A9%94%EC%8B%9C%EC%A7%80-%EC%A0%84%EC%86%A1%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95-84199f0b12d9)
- [Building a Cross-Chain Swap with LayerZero](https://blog.developerdao.com/building-a-cross-chain-swap-with-layerzero)