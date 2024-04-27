# CCIP Demo

## On-chain Greeting

### Deploy Greeting Receiver to Sepolia

```bash
$ forge script script/GreetingSender.s.sol --rpc-url sepolia --account piatoss --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF --broadcast -vvvv --sig "deploy(uint8,bool)" -- 0 true

...

== Logs ==
  Transfered 1 LINK to GreetingSender
  GreetingSender deployed at 0x44E0967e2Ea92287039F015E205E801cADa2cfe2
```

### Deploy Greeting Sender to Optimism

```bash
$ forge script script/GreetingReceiver.s.sol --rpc-url optimism --account piatoss --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF --broadcast -vvvv --sig "deploy(uint8,bool)" -- 5 false

...

== Logs ==
  GreetingReceiver deployed at 0x44f21c4a4dcC4A70De5450c2E2D4778c874F6507
```

### Set Greeting Receiver's address in Greeting Sender

```bash
$ forge script script/GreetingSender.s.sol --rpc-url sepolia --account piatoss --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF --broadcast -vvvv --sig "setSender(address,address,uint8)" -- 0x44E0967e2Ea92287039F015E205E801cADa2cfe2 0x44f21c4a4dcC4A70De5450c2E2D4778c874F6507 5

...

== Logs ==
  GreetingReceiver set to 0x44f21c4a4dcC4A70De5450c2E2D4778c874F6507
```

### Set Greeting Sender's address in Greeting Receiver

```bash
$ forge script script/GreetingReceiver.s.sol --rpc-url optimism --account piatoss --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF --broadcast -vvvv --sig "setSender(address,address,uint8)" -- 0x44f21c4a4dcC4A70De5450c2E2D4778c874F6507 0x44E0967e2Ea92287039F015E205E801cADa2cfe2 0

...

== Logs ==
  GreetingSender set to 0x44E0967e2Ea92287039F015E205E801cADa2cfe2
```

### Send Greeting

```bash
$ forge script script/GreetingSender.s.sol --rpc-url sepolia --account piatoss --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF --broadcast -vvvv --sig "sendGreeting(address,string,uint8)" -- 0x44E0967e2Ea92287039F015E205E801cADa2cfe2 "Hello from Sepolia!" 5

...

== Logs ==
  GreetingSender sent message to 0x44f21c4a4dcC4A70De5450c2E2D4778c874F6507
```

### Receive Greeting

- took about 22 minutes to get the message
- [Transaction Detail](https://ccip.chain.link/msg/0x509ab7b6e954efb7be00f81c312d4e846b9e5d176de0ecf82bec99438d213f31)

```bash
$ forge script script/GreetingReceiver.s.sol --rpc-url optimism --account piatoss --sender 0x965B0E63e00E7805569ee3B428Cf96330DFc57EF -vvvv --sig "readMessage(address,uint256)" -- 0x44f21c4a4dcC4A70De5450c2E2D4778c874F6507 0

== Logs ==
  Message 0 : Hello from Sepolia!
```

## Local Testing

- Using `CCIPLocalSimulator` to test the contracts locally

```bash
$ forge test
[⠒] Compiling...
[⠒] Compiling 1 files with 0.8.24
[⠢] Solc 0.8.24 finished in 3.86s
Compiler run successful!

Ran 1 test for test/Greeting.t.sol:GreetingTest
[PASS] test_SendGreeting() (gas: 109468)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.20ms (255.50µs CPU time)

Ran 1 test for test/TokenTransfer.t.sol:TokenTransferTest
[PASS] test_TransferToken() (gas: 175692)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.30ms (289.40µs CPU time)

Ran 2 test suites in 55.88ms (2.49ms CPU time): 2 tests passed, 0 failed, 0 skipped (2 total tests)
```
