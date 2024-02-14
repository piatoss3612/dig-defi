# Web3OJ Solutions

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

## 21. Run With ABI

- `cast` 명령어를 사용하여 스마트 컨트랙트의 런타임 바이트코드로부터 함수 선택자와 파라미터 타입을 확인합니다.

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

- `cast` 명령어를 사용하여 스마트 컨트랙트 스토리지의 `0`번째 슬롯에 저장된 값을 확인합니다.

```bash
$ cast storage 0xbE1DdAB9F36100ca9c51ce44BF3A61637fc3c355 0 --rpc-url mumbai
0x00000000000000000000000000000000000000000000000000000000000002e0
```

```bash
$ forge script script/22/FindPrivateValue.s.sol --rpc-url mumbai --broadcast -vvvv
```

## 23. Run With ABI2 : Delegation of Authority

- `cast` 명령어를 사용하여 스마트 컨트랙트의 런타임 바이트코드로부터 함수 선택자와 파라미터 타입을 확인합니다.

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
