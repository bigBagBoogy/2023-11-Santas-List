# invariants:

In order for someone to be considered NICE or EXTRA_NICE they must be first "checked twice" by Santa.

missing access control  SantasList::checkList

# issues:
Running 1 test for test/unit/invariant/Invariant.t.sol:Invariant
[FAIL. Reason: failed to set up invariant testing environment: No contracts to fuzz.] statefulFuzz_onlySantaCan() (runs: 0, calls: 0, reverts: 0)

If you see this error you failed to correctly initialize and deploy the target contract
e.g. ```santasList = new SantasList();```
