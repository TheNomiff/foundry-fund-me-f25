// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // import Chainlink's AggregatorV3Interface
import {PriceConverter} from "./PriceConverter.sol"; // import our PriceConverter library

error FundMe__NotOwner(); // custom error for not owner

contract FundMe {
    using PriceConverter for uint256; // attach PriceConverter library functions to uint256 type

    /* State variables */

    mapping(address => uint256) private s_addressToAmountFunded; // mapping to track amount funded by each address
    address[] private s_funders; // array of funder addresses

    // Could we make this constant?  /* hint: no! We should make it immutable! */

    address private immutable i_owner; // owner of the contract
    uint256 public constant MINIMUM_USD = 5e18; // minimum USD amount to fund
    AggregatorV3Interface private s_priceFeed; // price feed interface

    /* Functions */

    constructor(address priceFeed) {
        i_owner = msg.sender; // set contract deployer as owner
        s_priceFeed = AggregatorV3Interface(priceFeed); // initialize price feed
    }

    function fund() public payable {
        // function to fund the contract
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, // check if sent ETH is at least MINIMUM_USD
            "You need to spend more ETH!" // revert with message if not enough ETH
        );
        s_addressToAmountFunded[msg.sender] += msg.value; // update funded amount for sender address
        s_funders.push(msg.sender); // add sender to funders array
    }

    function getVersion() public view returns (uint256) {
        // function to get price feed version
        return s_priceFeed.version(); // return version from price feed
    }

    modifier onlyOwner() {
        // modifier to restrict access to owner
        if (msg.sender != i_owner) revert FundMe__NotOwner(); // use custom error
        _;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length; // cache funders array length
        for(uint256 fundersIndex = 0; fundersIndex < fundersLength; fundersIndex++){
            address funder = s_funders[fundersIndex]; // get funder address
            s_addressToAmountFunded[funder] = 0; // reset funded amount
        }
        s_funders = new address[](0); // reset funders array
    }

    function withdraw() public onlyOwner {
        // function to withdraw funds, only callable by owner
        for (
            // loop through funders
            uint256 funderIndex = 0; // start index
            funderIndex < s_funders.length; // loop condition
            funderIndex++
        ) {
            address funder = s_funders[funderIndex]; // get funder address
            s_addressToAmountFunded[funder] = 0; // reset funded amount
        }
        s_funders = new address[](0); // reset funders array

        /* Withdraw the funds */

        (bool callSuccess, ) = payable(msg.sender).call{ // call method to send funds
            value: address(this).balance
        }(""); // send entire contract balance
        require(callSuccess, "Call failed"); // require call was successful
    }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    /* Fallback and Receive functions */

    fallback() external payable {
        // fallback function to handle calls with data
        fund();
    }

    receive() external payable {
        // receive function to handle plain ETH transfers
        fund();
    }

    /* Getters */

    function getAddressToAmountFunded(
        // getter for funded amount by address
        address fundingAddress // address to check
    ) external view returns (uint256) {
        // return funded amount
        return s_addressToAmountFunded[fundingAddress]; // return funded amount
    }

    function getFunder(uint256 index) public view returns (address) {
        // getter for funder address by index
        return s_funders[index]; // return funder address
    }

    function getOwner() external view returns (address) {
        // getter for contract owner
        return i_owner; // return owner address
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly