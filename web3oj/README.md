# Web3OJ Solutions

## Introduction

- [Web3OJ](https://app.web3oj.com)에서 제공하는 문제들을 `foundry`를 사용하여 풀어봅니다.

## Table of Contents

- [01. 덧셈](#01-덧셈)
- [02. 뺄셈](#02-뺄셈)
- [03. 곱셈](#03-곱셈)
- [04. 나눗셈](#04-나눗셈)
- [05. ERC-20 토큰 만들기](#05-erc-20-토큰-만들기)
- [06. ERC-20 송금](#06-erc-20-송금)
- [07. ERC-20 인출 허용하기](#07-erc-20-인출-허용하기)
- [08. ERC-20 인출하기](#08-erc-20-인출하기)
- [09. ERC-20 Mint 위임하기](#09-erc-20-mint-위임하기)
- [10. ERC-20 소각하기](#10-erc-20-소각하기)
- [11. ERC-20 일시정지](#11-erc-20-일시정지)
- [12. ERC-20 Permit](#12-erc-20-permit)
- [13. ERC-721 NFT 만들기](#13-erc-721-nft-만들기)
- [14. ERC-721 인출 허용하기](#14-erc-721-인출-허용하기)
- [15. ERC-721 인출하기](#15-erc-721-인출하기)
- [16. ERC-721 소각하기](#16-erc-721-소각하기)
- [17. ERC-721 일시정지](#17-erc-721-일시정지)
- [18. ERC-721 찾아서 송금하기](#18-erc-721-찾아서-송금하기)
- [19. ERC-721 Mint 위임하기](#19-erc-721-mint-위임하기)
- [20. ERC-721 Mint 위임하기(Auto Increment Ids)](#20-erc-721-mint-위임하기auto-increment-ids)
- [21. Run With ABI](#21-run-with-abi)
- [22. Private Value 찾기](#22-private-value-찾기)
- [23. Run With ABI2 : Delegation of Authority](#23-run-with-abi2--delegation-of-authority)
- [24. ETH 송금하고 받기](#24-eth-송금하고-받기)
- [25. 좌물쇠 풀기](#25-좌물쇠-풀기)
- [26. 문자열 비교](#26-문자열-비교)
- [27. 에러 메시지 처리하기](#27-에러-메시지-처리하기)
- [28. 에러 코드 처리하기](#28-에러-코드-처리하기)
- [29. 에러 데이터 처리하기](#29-에러-데이터-처리하기)
- [30. 배열의 합 구하기](#30-배열의-합-구하기)
- [31. 휴면계좌에 이더 넣기](#31-휴면계좌에-이더-넣기)

## 01. 덧셈

```bash
$ forge script script/01/PlusCalculator.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 02. 뺄셈

```bash
$ forge script script/02/MinusCalculator.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 03. 곱셈

```bash
$ forge script script/03/MultiplicationCalculator.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 04. 나눗셈

```bash
$ forge script script/04/DivisionCalculator.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 05. ERC-20 토큰 만들기

```bash
$ forge script script/05/ERC20Init.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 06. ERC-20 송금

```bash
$ forge script script/06/ERC20Transfer.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 07. ERC-20 인출 허용하기

```bash
$ forge script script/07/ERC20Approve.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 08. ERC-20 인출하기

```bash
forge script script/08/ERC20TransferFrom.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 09. ERC-20 Mint 위임하기

```bash
$ forge script script/09/ERC20Mintable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 10. ERC-20 소각하기

```bash
$ forge script script/10/ERC20Burnable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 11. ERC-20 일시정지

```bash
$ forge script script/11/ERC20Pausable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 12. ERC-20 Permit

```bash
$ forge script script/12/ERC20Permitable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 13. ERC-721 NFT 만들기

```bash
$ forge script script/13/ERC721Init.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 14. ERC-721 인출 허용하기

```bash
$ forge script script/14/ERC721Approve.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 15. ERC-721 인출하기

```bash
$ forge script script/15/ERC721TransferFrom.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 16. ERC-721 소각하기

```bash
$ forge script script/16/ERC721Burnable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 17. ERC-721 일시정지

```bash
$ forge script script/17/ERC721Pausable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 18. ERC-721 찾아서 송금하기

- `cast logs` 명령어를 사용하여 `Transfer` 이벤트를 확인합니다.

```bash
$ cast logs 'Transfer(address indexed from, address indexed to, uint256 indexed tokenId)' --address 0xD2dD0DdDBcdBd262120F411a45B271BcA3c87587 --rpc-url mumbai --from-block 45894049 --to-block latest
- address: 0xD2dD0DdDBcdBd262120F411a45B271BcA3c87587
  blockHash: 0xa8a6e310d73cad957895bdcaec939ff68092412ea98c886931296bf3ac722e9a
  blockNumber: 45894048
  data: 0x
  logIndex: 75
  removed: false
  topics: [
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
        0x0000000000000000000000000000000000000000000000000000000000000000
        0x000000000000000000000000965b0e63e00e7805569ee3b428cf96330dfc57ef
        0x00000000000000000000000000000000000000000000000000000000000002f0
  ]
  transactionHash: 0x596cd46566ebccf2380ede1b92b07a24d46ed052ceeb63583c31b25d364a2ac5
  transactionIndex: 29
```

- 토큰 id는 `0x2f0`입니다.

```bash
$ forge script script/18/ERC721FindTransfer.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 19. ERC-721 Mint 위임하기

```bash
$ forge script script/19/ERC20Mintable.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 20. ERC-721 Mint 위임하기(Auto Increment Ids)

```bash
$ forge script script/20/ERC20Mintable2.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 21. Run With ABI

- `cast selectors` 명령어를 사용하여 스마트 컨트랙트의 런타임 바이트코드로부터 함수 선택자와 파라미터 타입을 확인합니다.

```bash
$ cast selectors $(cast code 0x9843A771650a28de6d9ba52C38ca37F8870989c2 --rpc-url mumbai)
0x38cc4831
0xa146bf7a
0xda17c605      address
```

- 이 중 calldata를 사용해 상태를 변경하는 함수는 `0xda17c605`입니다.

```bash
$ forge script script/21/RunWithABI.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 22. Private Value 찾기

- `cast storage` 명령어를 사용하여 스마트 컨트랙트 스토리지의 `0`번째 슬롯에 저장된 값을 확인합니다.

```bash
$ cast storage 0xbE1DdAB9F36100ca9c51ce44BF3A61637fc3c355 0 --rpc-url mumbai
0x00000000000000000000000000000000000000000000000000000000000002e0
```

```bash
$ forge script script/22/FindPrivateValue.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 23. Run With ABI2 : Delegation of Authority

- `cast selectors` 명령어를 사용하여 스마트 컨트랙트의 런타임 바이트코드로부터 함수 선택자와 파라미터 타입을 확인합니다.

```bash
$ cast selectors $(cast code 0xF8E07835C94aC985821d45B0a468679790035683 --rpc-url mumbai)
0x7ce22076
0xa6e5ca07
0xacbe8452
0xb73c4816      address
```

- 이 중 `0xb73c4816` 함수는 문제에서 확인할 수 있는 `setRunWithABI2` 함수입니다.
- 스토리지의 `0`번 슬롯의 값을 변경하는 함수는 `0xa6e5ca07`입니다.

```bash
$ forge script script/23/RunWithABI2.s.sol:RunWithABI2Script --rpc-url mumbai --broadcast -vvvv
```

## 24. ETH 송금하고 받기

- `cast selectors` 명령어를 사용하여 스마트 컨트랙트의 런타임 바이트코드로부터 함수 선택자와 파라미터 타입을 확인합니다.

```bash
0x11d2cb63      address
0x325ec768
0xf6b4dfb4
```

- `cast 4byte` 명령어를 사용해 함수 선택자로부터 함수 시그니처를 확인합니다.

```bash
$ cast 4byte 0x325ec768
sendEtherToContract()
```

```bash
$ cast 4byte 0xf6b4dfb4
contractAddress()
```

- `sendEtherToContract` 함수를 사용해 이더를 스마트 컨트랙트로 송금할 수 있습니다.
- 또는 스마트 컨트랙트에 fallback 함수가 정의되어 있으므로 `send`, `transfer`, `call` 함수를 사용해 이더를 스마트 컨트랙트로 송금할 수 있습니다.

```bash
$ forge script script/24/ReceiveEther.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 25. 좌물쇠 풀기

```bash
$ forge script script/25/Lock.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 26. 문자열 비교

```bash
$ forge script script/26/StringCompare.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 27. 에러 메시지 처리하기

```bash
$ forge script script/27/ErrorHandle.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 28. 에러 코드 처리하기

```bash
$ forge script script/27/ErrorHandle2.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 29. 에러 데이터 처리하기

```bash
$ forge script script/29/ErrorHandle3.s.sol:ErrorHandle3Script --rpc-url mumbai --broadcast -vvvv
```

## 30. 배열의 합 구하기

```bash
$ forge script script/30/SumOfArray.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 31. 휴면계좌에 이더 넣기

```bash
$ forge script script/31/DormantAccount.s.sol --rpc-url mumbai --broadcast -vvvv
```
