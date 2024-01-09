// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test, StdInvariant, console2} from "forge-std/Test.sol";
import {SantasList} from "src/SantasList.sol";

contract Invariant is StdInvariant, Test {
    SantasList santasList;

    function setUp() public {
        santasList = new SantasList();
    }

    function statefulFuzz_onlySantaCan() public {
        console2.log("onlyStdInvariant");
    }
}
