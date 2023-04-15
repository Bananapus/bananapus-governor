// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Governor.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract CounterTest is Test {
    MockERC20Votes public votes;
    Governor public governor_implementation;
    ERC1967Proxy public proxy;

    // Same as proxy, but correct interface for usage
    Governor public governor;

    uint256 private constant ONE_WEEK = 1 weeks / 12 seconds;

    function setUp() public {
        // Deploy an IVotes
        votes = new MockERC20Votes();

        // Configure UUPS proxy
        governor_implementation = new Governor();
        proxy = new ERC1967Proxy(
            address(governor_implementation),
            abi.encodeWithSelector(
                Governor.initialize.selector,
                "GenericGovernor",
                IVotes(address(votes))
            )
        );

        governor = Governor(payable(address(proxy)));
    }

    function testUpgrade() public {
        address _proposer = address(0xdeadbeef);
        address _upgradeTarget = address(new MockUpgradeTarget());

        // Make the proposer delegate to themselves
        vm.prank(_proposer);
        votes.delegate(_proposer);

        // Give the proposer enough votes to pass the proposal when voting starts
        votes.mint(_proposer, 100_000);

        // Build the proposal
        address[] memory _targets = new address[](1);
        uint256[] memory _values = new uint256[](1);
        bytes[] memory _calldatas = new bytes[](1);

        _targets[0] = address(governor);
        _calldatas[0] = abi.encodeWithSelector(UUPSUpgradeable.upgradeTo.selector, _upgradeTarget);

        vm.prank(_proposer);
        uint256 _proposalId = governor.propose(_targets, _values, _calldatas, "");

        // Wait a week (+ 1 more block)
        vm.roll(block.number + ONE_WEEK + 1);

        // Vote on the proposal
        vm.prank(_proposer);
        // 1 is 'For'
        governor.castVote(_proposalId, 1);

        // Wait a week (+ 1 more block)
        vm.roll(block.number + ONE_WEEK + 1);
        governor.execute(_targets, _values, _calldatas, keccak256(""));

        // Verify that the governor is now upgraded to the mockTarget
        assertEq(MockUpgradeTarget(address(governor)).successfulUpgrade(), true);
    }
}

contract MockERC20Votes is ERC20Votes {
    constructor() ERC20("Mock", "Mock") ERC20Permit("Mock") {}

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}

contract MockUpgradeTarget is UUPSUpgradeable {
    function _authorizeUpgrade(address newImplementation) internal virtual override {}

    function successfulUpgrade() public pure returns (bool) {
        return true;
    }
}
