// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function test_MinimumIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // 5 * 10**18
    }

    function test_OwnerIsSender() public view {
        assertEq(fundMe.getOwner(), msg.sender); // owner is deployer of the contract
    }

    function test_PriceVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion(); // should be 4 for Goerli ETH/USD Price Feed
        assertEq(version, 4); // assert version is 4
    }

    function test_FundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // next tx should revert
        fundMe.fund(); // 0.00 ETH
    }

    function test_FundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next tx will be sent by USER

        fundMe.fund{value: SEND_VALUE}(); // 10 ETH
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); // get amount funded
        assertEq(amountFunded, SEND_VALUE); // check if amount funded is correct
    }

    function test_AddsFunderToArrayOfFunders() public {
        vm.prank(USER); // The next tx will be sent by USER

        fundMe.fund{value: SEND_VALUE}(); // 10 ETH
        address funder = fundMe.getFunder(0); // get first funder
        assertEq(funder, USER); // check if funder is USER
    }

    modifier funded() {
        vm.prank(USER); // The next tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // 10 ETH
        _;
    }

    function test_OnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // The next tx will be sent by USER But USER is not the owner
        vm.expectRevert(); // next tx should revert
        fundMe.withdraw(); // withdraw funds
    }

    function test_WithdrawWithASingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // get owner balance
        uint256 startingFundMeBalance = address(fundMe).balance; // get contract balance

        // act
        vm.txGasPrice(GAS_PRICE); // set gas price
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // should have spent gas?

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // get owner balance after withdraw
        uint256 endingFundMeBalance = address(fundMe).balance; // get contract balance after withdraw

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function test_WithdrawFromMultipleFunders() public funded {

        // Arrange
        uint160 numbersOfFunders = 10; // 10 funders
        uint160 startingFundersIndex = 1; // start from index 1 to avoid msg.sender being owner
        for(uint160 i = startingFundersIndex; i < numbersOfFunders; i++){
            // vm.prank
            // vm.deal
            // address funder = address(uint160(i)); // create a fake address for testing

            hoax(address(i), SEND_VALUE); // give address i 10 ETH and set msg.sender to address i
            fundMe.fund{value: SEND_VALUE}(); // fund the contract
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance; // get owner balance
        uint256 startingFundMeBalance = address(fundMe).balance; // get contract balance

        // Act
        vm.startPrank(fundMe.getOwner()); // Get owner to withdraw funds
        fundMe.withdraw(); // call withdraw function to withdraw funds
        vm.stopPrank(); // stop pranking

        // Assert
        assert(address(fundMe).balance == 0); // contract balance should be 0
        assert(
            startingFundMeBalance + startingOwnerBalance == // owner balance should be increased by contract balance
                fundMe.getOwner().balance // get owner balance
            ); // assert equality
    }

    // function test_WithdrawFromMultipleFundersCheaper() public funded {

    //     // Arrange
    //     uint160 numbersOfFunders = 10; // 10 funders
    //     uint160 startingFundersIndex = 1; // start from index 1 to avoid msg.sender being owner
    //     for(uint160 i = startingFundersIndex; i < numbersOfFunders; i++){
    //         // vm.prank
    //         // vm.deal
    //         // address funder = address(uint160(i)); // create a fake address for testing

    //         hoax(address(i), SEND_VALUE); // give address i 10 ETH and set msg.sender to address i
    //         fundMe.fund{value: SEND_VALUE}(); // fund the contract
    //     }

    //     uint256 startingOwnerBalance = fundMe.getOwner().balance; // get owner balance
    //     uint256 startingFundMeBalance = address(fundMe).balance; // get contract balance

    //     // Act
    //     vm.startPrank(fundMe.getOwner()); // Get owner to withdraw funds
    //     fundMe.cheaperWithdraw(); // call cheaper withdraw function to withdraw funds
    //     vm.stopPrank(); // stop pranking

    //     // Assert
    //     assert(address(fundMe).balance == 0); // contract balance should be 0
    //     assert(
    //         startingFundMeBalance + startingOwnerBalance == // owner balance should be increased by contract balance
    //             fundMe.getOwner().balance // get owner balance
    //         ); // assert equality
    // }

}