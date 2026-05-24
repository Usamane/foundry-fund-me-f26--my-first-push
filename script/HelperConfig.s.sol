// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//1. Deploy mock when we are on a local anvill chain
//2. Keep track of contract address across different chains 
// Sepolia ETH/USD 
// mainnet ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
   // if we are on a local anvil chain, we deploy mocks
  // otherwise, we grab the existing address from the live network
  NetworkConfig public activeNetworkConfig; 

  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8; // 2000 dollars
  

  struct NetworkConfig {
    address priceFeed; // ETH/USD price feed address
  }

    constructor() {
        if (block.chainid == 11155111) {
        activeNetworkConfig = getSepoliaEthConfig();
        }
        else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
         else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

  function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    // what we only need from sepolia is price feed address
    // what if we have bunch of stuf we need eg. like vrf address gas price (this is where struct comes in)
    NetworkConfig memory sepoliaConfig = NetworkConfig({
        priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
    return sepoliaConfig;
  }

   function getMainnetEthConfig() public pure returns (NetworkConfig memory) { 
    NetworkConfig memory ethConfig = NetworkConfig({
        priceFeed:0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    return ethConfig;
  }

  function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
    if (activeNetworkConfig.priceFeed != address(0)) {
        return activeNetworkConfig;
    }
    // which also need price feed address, but we will deploy a mock in this case
    // return the mock address
    

    vm.startBroadcast();

    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
     DECIMALS,  // decimals,
      INITIAL_PRICE   //initial answer
      ); 
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
        priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    
  }
}