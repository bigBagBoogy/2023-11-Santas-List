# What is the entry point of the contract?
a - adding a person to the `s_theListCheckedOnce` mapping
santasList::checkList(address person, Status status)  does this
b - same as a, but now `s_theListCheckedTwice`


# invariants:

In order for someone to be considered NICE or EXTRA_NICE they must be first "checked twice" by Santa.

missing access control  SantasList::checkList

# issues:
Running 1 test for test/unit/invariant/Invariant.t.sol:Invariant
[FAIL. Reason: failed to set up invariant testing environment: No contracts to fuzz.] statefulFuzz_onlySantaCan() (runs: 0, calls: 0, reverts: 0)

If you see this error you failed to correctly initialize and deploy the target contract
e.g. ```santasList = new SantasList();```


SantaToken.constructor(address).santasList (src/SantaToken.sol#17) 
## lacks a zero-check on : - i_santasList = santasList (src/SantaToken.sol#18)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#missing-zero-address-validation

## Reentrancy in SantasList.buyPresent(address) (src/SantasList.sol#129-132):
        External calls:
        - i_santaToken.burn(presentReceiver) (src/SantasList.sol#130)
        - _mintAndIncrement() (src/SantasList.sol#131)
                - retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#467-480)
        Event emitted after the call(s):
        - Approval(owner,to,tokenId) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#419)
                - _mintAndIncrement() (src/SantasList.sol#131)
        - Transfer(from,to,tokenId) (lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#267)
                - _mintAndIncrement() (src/SantasList.sol#131)
Reference: https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-3
