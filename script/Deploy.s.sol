// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {IVotes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Governor} from "../src/Governor.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // Deploy the governor (or reuse existing implementation)
        Governor governor_implementation = new Governor();

        // Bananapus (NANA) ERC20 Votes token
        IVotes votes = IVotes(address(0x8fa968D64dF15C0b6949843E4355195553246bbd));

        // Deploy the UUPS proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(governor_implementation),
            abi.encodeWithSelector(
                Governor.initialize.selector,
                "Bananapus",
                address(votes)
            )
        );

        vm.stopBroadcast();

        console.log("Implementation at %s", address(governor_implementation));
        console.log("UUPS proxy deployed at %s", address(proxy));
    }
}
