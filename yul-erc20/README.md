# ERC-20 with Inline Assembly

## Description

This is a simple ERC-20 impelementation using inline assembly referring to the OpenZeppelin implementation.

> Only for educational purposes. Do not use in production.

## Requirements

- [foundry](https://book.getfoundry.sh/getting-started/installation)
- [solc](https://docs.soliditylang.org/en/latest/installing-solidity.html)

## Test Coverage

```shell
$ $ forge coverage --mc ERC20ATest
[⠒] Compiling...
[⠃] Compiling 26 files with 0.8.24
[⠒] Solc 0.8.24 finished in 4.70s
Compiler run successful!
Analysing contracts...
Running tests...
| File                    | % Lines         | % Statements    | % Branches      | % Funcs         |
|-------------------------|-----------------|-----------------|-----------------|-----------------|
| src/ERC20A.sol          | 100.00% (37/37) | 100.00% (30/30) | 100.00% (10/10) | 100.00% (16/16) |
| src/test/TestERC20A.sol | 100.00% (4/4)   | 100.00% (4/4)   | 100.00% (0/0)   | 100.00% (4/4)   |
| Total                   | 100.00% (41/41) | 100.00% (34/34) | 100.00% (10/10) | 100.00% (20/20) |
```

## Gas Report

### ERC20A

```shell
$ $ forge test --mc ERC20ATest --gas-report
[⠒] Compiling...
No files changed, compilation skipped

Running 25 tests for test/ERC20A.t.sol:ERC20ATest
...
Test result: ok. 25 passed; 0 failed; 0 skipped; finished in 4.04ms
| src/test/TestERC20A.sol:TestERC20A contract |                 |       |        |       |         |
|---------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                             | Deployment Size |       |        |       |         |
| 463126                                      | 2573            |       |        |       |         |
| Function Name                               | min             | avg   | median | max   | # calls |
| allowance                                   | 759             | 1330  | 759    | 2759  | 7       |
| approve(address,address,uint256)            | 589             | 589   | 589    | 589   | 1       |
| approve(address,uint256)                    | 456             | 18027 | 23534  | 24584 | 4       |
| balanceOf                                   | 545             | 1420  | 545    | 2545  | 16      |
| burn                                        | 448             | 4540  | 716    | 12457 | 3       |
| decimals                                    | 245             | 245   | 245    | 245   | 2       |
| mint                                        | 492             | 10925 | 2674   | 29609 | 3       |
| name                                        | 677             | 2677  | 2677   | 4677  | 2       |
| symbol                                      | 732             | 2732  | 2732   | 4732  | 2       |
| totalSupply                                 | 326             | 826   | 326    | 2326  | 4       |
| transfer(address,address,uint256)           | 529             | 537   | 537    | 546   | 2       |
| transfer(address,uint256)                   | 696             | 14196 | 14196  | 27697 | 2       |
| transferFrom                                | 2853            | 19841 | 28153  | 28519 | 3       |
```

### ERC20 (OpenZeppelin)

```shell
$ forge test --mc ERC20OTest --gas-report
[⠒] Compiling...
No files changed, compilation skipped

Running 23 tests for test/ERC20O.t.sol:ERC20OTest
...
Test result: ok. 23 passed; 0 failed; 0 skipped; finished in 2.33ms
| src/test/TestERC20O.sol:TestERC20O contract |                 |       |        |       |         |
|---------------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                             | Deployment Size |       |        |       |         |
| 515667                                      | 3509            |       |        |       |         |
| Function Name                               | min             | avg   | median | max   | # calls |
| allowance                                   | 792             | 1363  | 792    | 2792  | 7       |
| approve(address,address,uint256)            | 658             | 658   | 658    | 658   | 1       |
| approve(address,uint256)                    | 543             | 18165 | 23689  | 24739 | 4       |
| balanceOf                                   | 563             | 1438  | 563    | 2563  | 16      |
| burn                                        | 517             | 4688  | 855    | 12693 | 3       |
| decimals                                    | 266             | 266   | 266    | 266   | 2       |
| mint                                        | 561             | 11033 | 2739   | 29800 | 3       |
| name                                        | 1178            | 2178  | 2178   | 3178  | 2       |
| symbol                                      | 1222            | 2222  | 2222   | 3222  | 2       |
| totalSupply                                 | 326             | 826   | 326    | 2326  | 4       |
| transfer(address,address,uint256)           | 598             | 615   | 615    | 633   | 2       |
| transfer(address,uint256)                   | 853             | 14398 | 14398  | 27944 | 2       |
| transferFrom                                | 2959            | 20081 | 28423  | 28862 | 3       |
```

### Comparison in Gas Usage (ERC20A vs ERC20)

- take the average gas usage of each function
- exclude `approve(address,address,uint256)` and `transfer(address,address,uint256)` functions these are just for testing purposes.

| Function Name             | ERC20A (gas) | ERC20 (gas) |
| ------------------------- | ------------ | ----------- |
| allowance                 | 1330         | 1363        |
| approve(address,uint256)  | 18027        | 18165       |
| balanceOf                 | 1420         | 1438        |
| burn                      | 4540         | 4688        |
| decimals                  | 245          | 266         |
| mint                      | 10925        | 11033       |
| name                      | 2677         | 2178        |
| symbol                    | 2732         | 2222        |
| totalSupply               | 826          | 826         |
| transfer(address,uint256) | 14196        | 14398       |
| transferFrom              | 19841        | 20081       |

- In most cases, ERC20A uses less gas than ERC20.
- ERC20A uses more gas in `name` and `symbol` functions.

## References

- [OpenZeppelin ERC20](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol)
- [Yul ERC20](https://github.com/kassandraoftroy/yulerc20)
- [Storage and memory layout of strings](https://ethereum.stackexchange.com/questions/107282/storage-and-memory-layout-of-strings)
- [Yul/Inline Assembly: Revert with a custom error message](https://ethereum.stackexchange.com/questions/142752/yul-inline-assembly-revert-with-a-custom-error-message)
