// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
interface IDisasterReliefFactory {
    event DisasterReliefDeployed(address disasterReliefAddress, string disasterName, uint256 initialFunds);
    
    function deployDisasterRelief(
        string memory disasterName, 
        string memory area, 
        uint256 donationPeriod, 
        uint256 registrationPeriod,
        uint256 waitingPeriod,
        uint256 distributionPeriod,
        uint256 initialFunds
    ) external returns (address);
    
    function getDeployedContracts() external view returns (address[] memory);
}
