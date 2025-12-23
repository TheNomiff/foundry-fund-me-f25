// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// 1. Deploy mocks when se are on a local anvil chain
// 2. keep track of contract address across different chains.
// Sepolia ETH/USD
// Mainnet ETH/USD

contract HelperConfig is Script {
    // if we are on a local anvil, we deploy mocks
    // otherwise, grab the existing address from the live network

    // state
    NetworkConfig public activeNetworkConfig;

    // Magic Numbers
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoilaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoilaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {

        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // Deploy the mocks
        // Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, // decimals of eth price feed is 8
            INITIAL_ANSWER // 2000 USD
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }   
}

// Lesson 7
// Refactoring III Mocks : 54:32
// Magic numbers : 58:40
// Refactoring III. Mocking (continued) 1:00:40
// chisel
// Gas cheaper withdraw : 1:33:51
// Storage : 1:38:37
// Gas: Cheaper withdraw : 1:48:22
// Intraction.s.sol : 1:56:13
// Makefile : 2:10:58