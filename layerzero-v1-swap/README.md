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
$ forge script script/SetTrustAddressMumbai.s.sol:SetTrustAddressMumbaiScript --rpc-url mumbai --broadcast -vvvv
$ forge script script/SetTrustAddressSepolia.s.sol:SetTrustAddressSepoliaScript --rpc-url sepolia --broadcast -vvvv
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
$ forge script script/SendMessageSepolia.s.sol --rpc-url sepolia -vvvv
```

- check data after sending message

> it takes for a while to get the result.

```shell
$ forge script script/CheckDataMumbai.sol --rpc-url mumbai -vvvv
...
== Logs ==
  data:  Hello World from Sepolia
```

## References

- [Klaytn에서 LayerZero 크로스체인 메시지 전송하는 방법](https://medium.com/klaytn-kr/klaytn%EC%97%90%EC%84%9C-layerzero-%ED%81%AC%EB%A1%9C%EC%8A%A4%EC%B2%B4%EC%9D%B8-%EB%A9%94%EC%8B%9C%EC%A7%80-%EC%A0%84%EC%86%A1%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95-84199f0b12d9)