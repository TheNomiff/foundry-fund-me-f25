// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe; // declare FundMe variable
    address USER = makeAddr("user"); // create a fake address for testing
    uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; // we will give the user 10 ETH
    uint256 constant GAS_PRICE = 1; // 1 gwei

    function setUp() external {
        // us -> FundMeTest -> FundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe(); // create script instance
        fundMe = deployFundMe.run(); // deploy FundMe contract
        vm.deal(USER, STARTING_BALANCE); // give USER 10 ETH
    }

    function test_userCanFundInteractions() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assertEq(address(fundMe).balance, 0);
    }
}
