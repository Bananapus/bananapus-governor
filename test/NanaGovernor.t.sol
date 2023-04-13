// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NanaGovernor.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract CounterTest is Test {
    NanaGovernor public governor_implementation;
    ERC1967Proxy public proxy;
    NanaGovernor public governor;

    function setUp() public {
        // Configure UUPS proxy
        governor_implementation = new NanaGovernor();
        proxy = new ERC1967Proxy(
            address(governor_implementation),
            abi.encodeWithSelector(
                NanaGovernor.initialize.selector,
                IVotesUpgradeable(address(0x0))
            )
        );

        governor = NanaGovernor(payable(address(proxy)));
    }

    function testIncrement() public {
        // counter.increment();
        // assertEq(counter.number(), 1);
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
