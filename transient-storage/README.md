## Transient Storage

### Test

```bash
$ forge test --gas-report -vv
[⠒] Compiling...
No files changed, compilation skipped

Ran 4 tests for test/Counter.t.sol:CounterTest
[PASS] test_IncrementV0() (gas: 55653)
Logs:
  gas used:  48457

[PASS] test_IncrementV1() (gas: 51716)
Logs:
  gas used:  57699

[PASS] test_IncrementV2() (gas: 55860)
Logs:
  gas used:  48737

[FAIL. Reason: call did not revert as expected] test_RevertIncrementV3TwiceByNotClearingTS() (gas: 79876)
Suite result: FAILED. 3 passed; 1 failed; 0 skipped; finished in 1.20ms (737.30µs CPU time)
| src/Counter.sol:CounterV0 contract |                 |       |        |       |         |
|------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                    | Deployment Size |       |        |       |         |
| 104479                             | 264             |       |        |       |         |
| Function Name                      | min             | avg   | median | max   | # calls |
| increment                          | 43401           | 43401 | 43401  | 43401 | 1       |
| number                             | 281             | 281   | 281    | 281   | 1       |


| src/Counter.sol:CounterV1 contract |                 |       |        |       |         |
|------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                    | Deployment Size |       |        |       |         |
| 130939                             | 388             |       |        |       |         |
| Function Name                      | min             | avg   | median | max   | # calls |
| increment                          | 52694           | 52694 | 52694  | 52694 | 1       |
| number                             | 282             | 282   | 282    | 282   | 1       |


| src/Counter.sol:CounterV2 contract |                 |       |        |       |         |
|------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                    | Deployment Size |       |        |       |         |
| 131959                             | 393             |       |        |       |         |
| Function Name                      | min             | avg   | median | max   | # calls |
| increment                          | 43732           | 43732 | 43732  | 43732 | 1       |
| number                             | 281             | 281   | 281    | 281   | 1       |


| src/Counter.sol:CounterV3 contract |                 |       |        |       |         |
|------------------------------------|-----------------|-------|--------|-------|---------|
| Deployment Cost                    | Deployment Size |       |        |       |         |
| 124391                             | 358             |       |        |       |         |
| Function Name                      | min             | avg   | median | max   | # calls |
| increment                          | 26527           | 35077 | 35077  | 43627 | 2       |
| number                             | 281             | 281   | 281    | 281   | 1       |




Ran 1 test suite in 7.17ms (1.20ms CPU time): 3 tests passed, 1 failed, 0 skipped (4 total tests)

Failing tests:
Encountered 1 failing test in test/Counter.t.sol:CounterTest
[FAIL. Reason: call did not revert as expected] test_RevertIncrementV3TwiceByNotClearingTS() (gas: 79876)

Encountered a total of 1 failing tests, 3 tests succeeded
```
