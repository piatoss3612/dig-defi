## Transient Storage

### Test

```bash
$ forge test -vv --gas-report
[⠒] Compiling...
[⠒] Compiling 2 files with 0.8.24
[⠑] Solc 0.8.24 finished in 1.38s
Compiler run successful!

Ran 2 tests for test/Counter.t.sol:CounterTest
[PASS] test_IncrementV1() (gas: 51657)
Logs:
  gas used:  57564

[PASS] test_IncrementV2() (gas: 55858)
Logs:
  gas used:  48737

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 1.04ms (522.70µs CPU time)
| src/Counter.sol:CounterV1 contract |                 |       |        |       |         |
|------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                    | Deployment Size |       |        |       |         |
| 108803                             | 285             |       |        |       |         |
| Function Name                      | min             | avg   | median | max   | # calls |
| increment                          | 52508           | 52508 | 52508  | 52508 | 1       |
| number                             | 282             | 282   | 282    | 282   | 1       |


| src/Counter.sol:CounterV2 contract |                 |       |        |       |         |
|------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                    | Deployment Size |       |        |       |         |
| 131959                             | 393             |       |        |       |         |
| Function Name                      | min             | avg   | median | max   | # calls |
| increment                          | 43732           | 43732 | 43732  | 43732 | 1       |
| number                             | 281             | 281   | 281    | 281   | 1       |




Ran 1 test suite in 9.37ms (1.04ms CPU time): 2 tests passed, 0 failed, 0 skipped (2 total tests)
```
