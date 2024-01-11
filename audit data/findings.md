### [H-1]  SantasList::buyPresent let's user mint presents at the expense of any other arbitrary user.

**Description:** 
The SantasList::buyPresent function takes an address that should be of a user that will be granted and NFT gift. However, in the function, this address is used to pay (burn tokens) for this transaction and the present ends up being sent to the caller of the SantasList::buyPresent function.

**Impact:** Not only will this let a user, both intentially and unintentially mint presents at the expense of others, Is also sircomvents the check to limit the amount of NFT's a user can mint:
```javascript
if (balanceOf(msg.sender) > 0) {
            revert SantasList__AlreadyCollected();
        }
```  

**Proof of Concept:**
Paste the below code at the bottom of the test SantasListTest.t.sol

```javascript
    function testMaartenCanMintHimselfAnNFTAtBabarasExpense() public maartenIsExtraNice barbaraIsExtraNice {
        assertEq(santasList.balanceOf(maarten), 1);
        // it's christmas and maarten is extra nice, but he will do
        // an naughty deed nontheless...
        // barbara starts off with 1 token...
        assertEq(santaToken.balanceOf(barbara), 1e18);
        // ... and maarten has 1 present
        assertEq(santasList.balanceOf(maarten), 1);
        vm.prank(maarten);
        santasList.buyPresent(barbara);
        // now barbara is left with 0 tokens and maarten has 2 presents
        assertEq(santaToken.balanceOf(barbara), 0);
        assertEq(santasList.balanceOf(maarten), 2);
}
```

**Recommended Mitigation:** 
```diff
function buyPresent(address presentReceiver) external {
-       i_santaToken.burn(presentReceiver);
+       i_santaToken.burn(msg.sender);
-       _mintAndIncrement();
+       _mintAndIncrement(presentReceiver);
    }

-    function _mintAndIncrement() private {
+    function _mintAndIncrement(address presentReceiver) private {
-        _safeMint(msg.sender, s_tokenCounter++);
+        _safeMint(presentReceiver, s_tokenCounter++);   
    }}
```
**Since SantasList::_mintAndIncrement now also takes an argument: `address presentReceiver`, this should also be adjusted in: SantasList::collectPresent.
like this:
``` diff
    if (s_theListCheckedOnce[msg.sender] == Status.NICE && s_theListCheckedTwice[msg.sender] == Status.NICE) {
-           _mintAndIncrement();
+           _mintAndIncrement(msg.sender);
            return;
        } else if (
            s_theListCheckedOnce[msg.sender] == Status.EXTRA_NICE
                && s_theListCheckedTwice[msg.sender] == Status.EXTRA_NICE
        ) {
-           _mintAndIncrement();
+           _mintAndIncrement(msg.sender);
            i_santaToken.mint(msg.sender);
            return;
        }
```
### [S-#]  missing access control 


**Description:** 
SantasList::checkList should be onlySanta

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:** 