// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;


import{Script,console} from "forge-std/Script.sol";
import {MockUSDC} from "../test/MockUSDC.sol";
contract DeployMockUSDC is Script{
    function run() external returns(address _mockUSDC){
        MockUSDC mockUSDC ;
        vm.startBroadcast();
        mockUSDC=new MockUSDC();
        console.log("USDC address",address(mockUSDC));
        vm.stopBroadcast();
        return address(mockUSDC);
}
}