// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {SantasList} from "../../src/SantasList.sol";
import {SantaToken} from "../../src/SantaToken.sol";
import {Test, console2} from "forge-std/Test.sol";
import {_CheatCodes} from "../mocks/CheatCodes.t.sol";

contract SantasListTest is Test {
    SantasList santasList;
    SantaToken santaToken;

    address user = makeAddr("user");
    address barbara = makeAddr("barbara");
    address maarten = makeAddr("maarten");
    address santa = makeAddr("santa");
    _CheatCodes cheatCodes = _CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        vm.startPrank(santa);
        santasList = new SantasList();
        santaToken = SantaToken(santasList.getSantaToken());
        vm.stopPrank();
    }

    modifier maartenIsExtraNice() {
        vm.startPrank(santa);
        santasList.checkList(maarten, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(maarten, SantasList.Status.EXTRA_NICE);
        vm.stopPrank();
        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        vm.prank(maarten);
        santasList.collectPresent();
        _;
    }

    modifier barbaraIsExtraNice() {
        vm.startPrank(santa);
        santasList.checkList(barbara, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(barbara, SantasList.Status.EXTRA_NICE);
        vm.stopPrank();
        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        vm.prank(barbara);
        santasList.collectPresent();
        _;
    }

    function testCheckList() public {
        vm.prank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.NICE));
    }

    function testBarbaraIsNAUGHTY() public {
        vm.prank(santa);
        santasList.checkList(barbara, SantasList.Status.NAUGHTY);
        if (uint256(santasList.getNaughtyOrNiceOnce(barbara)) == 2) {
            console2.log("BARBARA IS NAUGHTY");
        }
        assertEq(uint256(santasList.getNaughtyOrNiceOnce(barbara)), uint256(SantasList.Status.NAUGHTY));
    }

    function testBarbaraCannotMint() public {
        vm.prank(santa);
        santasList.checkList(barbara, SantasList.Status.NAUGHTY);
        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);
        // naughty barbara is going to try and mint an NFT
        vm.expectRevert();
        vm.prank(barbara);
        santasList.collectPresent();
        console2.log(uint256(santasList.getNaughtyOrNiceTwice(barbara)));
    }

    function testCheckListTwice() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        santasList.checkTwice(user, SantasList.Status.NICE);
        vm.stopPrank();

        assertEq(uint256(santasList.getNaughtyOrNiceOnce(user)), uint256(SantasList.Status.NICE));
        assertEq(uint256(santasList.getNaughtyOrNiceTwice(user)), uint256(SantasList.Status.NICE));
    }

    function testCantCheckListTwiceWithDifferentThanOnce() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        vm.expectRevert();
        santasList.checkTwice(user, SantasList.Status.NAUGHTY);
        vm.stopPrank();
    }

    function testCantCollectPresentBeforeChristmas() public {
        vm.expectRevert(SantasList.SantasList__NotChristmasYet.selector);
        santasList.collectPresent();
    }

    function testCantCollectPresentIfAlreadyCollected() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        santasList.checkTwice(user, SantasList.Status.NICE);
        vm.stopPrank();

        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);

        vm.startPrank(user);
        santasList.collectPresent();
        vm.expectRevert(SantasList.SantasList__AlreadyCollected.selector);
        santasList.collectPresent();
    }

    function testCollectPresentNice() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NICE);
        santasList.checkTwice(user, SantasList.Status.NICE);
        vm.stopPrank();

        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);

        vm.startPrank(user);
        santasList.collectPresent();
        assertEq(santasList.balanceOf(user), 1);
        vm.stopPrank();
    }

    function testCollectPresentExtraNice() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(user, SantasList.Status.EXTRA_NICE);
        vm.stopPrank();

        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);

        vm.startPrank(user);
        santasList.collectPresent();
        assertEq(santasList.balanceOf(user), 1);
        assertEq(santaToken.balanceOf(user), 1e18);
        vm.stopPrank();
    }

    function testCantCollectPresentUnlessAtLeastNice() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.NAUGHTY);
        santasList.checkTwice(user, SantasList.Status.NAUGHTY);
        vm.stopPrank();

        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);

        vm.startPrank(user);
        vm.expectRevert();
        santasList.collectPresent();
    }

    function testBuyPresent() public {
        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(user, SantasList.Status.EXTRA_NICE);
        vm.stopPrank();

        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);

        vm.startPrank(user);
        santaToken.approve(address(santasList), 1e18);
        santasList.collectPresent();
        santasList.buyPresent(user);
        assertEq(santasList.balanceOf(user), 2);
        assertEq(santaToken.balanceOf(user), 0);
        vm.stopPrank();
    }

    function testOnlyListCanMintTokens() public {
        vm.expectRevert();
        santaToken.mint(user);
    }

    function testOnlyListCanBurnTokens() public {
        vm.expectRevert();
        santaToken.burn(user);
    }

    function testTokenURI() public {
        string memory tokenURI = santasList.tokenURI(0);
        assertEq(tokenURI, santasList.TOKEN_URI());
    }

    function testGetSantaToken() public {
        assertEq(santasList.getSantaToken(), address(santaToken));
    }

    function testGetSanta() public {
        assertEq(santasList.getSanta(), santa);
    }

    /////  Segurigor  Tests    /////

    function testBuyingOthersPresentsWillGiveBuyerPresent() public {
        // if Santa did not check twice, The user does not have 2 token
        // if the user does not have 2 token it can not burn them in the `buyPresent()` function
        // This will stop execution, so no present will be minted

        vm.startPrank(santa);
        santasList.checkList(user, SantasList.Status.EXTRA_NICE);
        santasList.checkTwice(user, SantasList.Status.EXTRA_NICE);
        vm.stopPrank();
        // this puts out 1   for EXTRA_NICE
        assertEq(uint256(santasList.getNaughtyOrNiceTwice(user)), uint256(SantasList.Status.EXTRA_NICE));

        vm.warp(santasList.CHRISTMAS_2023_BLOCK_TIME() + 1);

        vm.startPrank(user);
        santasList.collectPresent();
        assertEq(santasList.balanceOf(user), 1); // nft
        assertEq(santaToken.balanceOf(user), 1e18); // 1 token

        // now user will call `buyPresent()`for barbara,
        // but this fails, because this functions internally tries
        // to burn barbara's token in stead of the user's token.
        // You'll first need to approve the SantasList contract to spend your SantaTokens.
        santaToken.approve(address(santasList), 1e18);
        santasList.buyPresent(barbara);
        // assertEq(santaToken.balanceOf(user), 0);
        assertEq(santasList.balanceOf(user), 2);

        // santasList.collectPresent();
        // santasList.buyPresent(user);

        // assertEq(santaToken.balanceOf(user), 0);  // token
        vm.stopPrank();
    }

    function testMaartenCanMintHimselfAnNFTAtBabarasExpense() public maartenIsExtraNice barbaraIsExtraNice {
        assertEq(santasList.balanceOf(maarten), 1);
        // it's christmas and maarten is extra nice, but he will do
        // an naughty deed nontheless...
        console2.log("barbara starts off having: ", santaToken.balanceOf(barbara), " tokens");
        // barbara starts off with 1 token...
        assertEq(santaToken.balanceOf(barbara), 1e18);
        // ... and maarten has 1 present
        assertEq(santasList.balanceOf(maarten), 1);
        vm.prank(maarten);
        santasList.buyPresent(barbara);
        console2.log("now barbara is left with: ", santaToken.balanceOf(barbara), " tokens");
        // now barbara is left with 0 tokens and maarten has 2 presents
        assertEq(santaToken.balanceOf(barbara), 0);
        assertEq(santasList.balanceOf(maarten), 2);
    }

    function test_H1mitigationFixesBuyPresent() public maartenIsExtraNice barbaraIsExtraNice {
        // for this test, temporarily implement the suggested fix.
        assertEq(santasList.balanceOf(maarten), 1);

        console2.log("barbara starts off having: ", santaToken.balanceOf(barbara), " tokens");
        console2.log("maarten starts off having: ", santaToken.balanceOf(maarten), " tokens");
        // barbara starts off with 1 token...
        assertEq(santaToken.balanceOf(barbara), 1e18);
        // ... and maarten has 1 present
        assertEq(santasList.balanceOf(maarten), 1);
        vm.prank(maarten);
        santasList.buyPresent(barbara);
        console2.log("now barbara is left with: ", santaToken.balanceOf(barbara), " tokens");
        console2.log("now barbara is left with: ", santasList.balanceOf(barbara), " tokens");

        assertEq(santaToken.balanceOf(barbara), 1e18);
        assertEq(santasList.balanceOf(barbara), 2); // barbara now has 2
        assertEq(santaToken.balanceOf(maarten), 0); // maarten spent his
        assertEq(santasList.balanceOf(maarten), 1);
    }
}
