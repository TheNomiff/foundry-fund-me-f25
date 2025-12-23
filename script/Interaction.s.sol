// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

// fund
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether; // make a constant for the value to send.

    function fundFundMe(address mostRecentlyDeployed) public {
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); // make this payable since we are sending eth
        console.log("Funded FundMe contract with %s", SEND_VALUE); // log the value sent
    }

    // if the {FundFundMe} contract is deployed directly, this run function will be called. thats why we will create this function {FundFundMe} above the run function.
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment( // this function gets the most recently deployed contract address
            "FundMe", // name of the contract
            block.chainid // this is identifier of the blockchain network
        );
        vm.startBroadcast();
        FundFundMe(mostRecentlyDeployed); // call the constructor with the most recently deployed address.
        vm.stopBroadcast(); 
    }
}

// withdraw
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();        
        FundMe(payable(mostRecentlyDeployed)).withdraw(); // make this payable since we are sending eth
        vm.stopBroadcast();
    }

    // if the {FundFundMe} contract is deployed directly, this run function will be called. thats why we will create this function {FundFundMe} above the run function.
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment( // this function gets the most recently deployed contract address
            "FundMe", // name of the contract
            block.chainid // this is identifier of the blockchain network
        );
        vm.startBroadcast();
        WithdrawFundMe(mostRecentlyDeployed); // call the constructor with the most recently deployed address.
        vm.stopBroadcast(); 
    }
}
