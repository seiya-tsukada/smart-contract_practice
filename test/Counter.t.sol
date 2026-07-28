// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    function test_InitialValueIsZero() public view {
        assertEq(counter.number(), 0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function test_SetNumber() public {
        counter.setNumber(42);
        assertEq(counter.number(), 42);
    }

    function test_RevertWhen_SameValue() public {
        vm.expectRevert("same value");
        counter.setNumber(0);
    }

    function testFuzz_SetNumber(uint256 x) public {
        vm.assume(x != 0);
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}