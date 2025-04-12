// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../src/LocationDetails.sol";

interface IDisasterRelief {
    enum ContractState {
        Donation,
        Registration,
        Waiting,
        Distribution,
        Closed
    }

    event DonationReceived(address indexed donor, uint256 amount);
    event VictimRegistered(address indexed victim);
    event FundsDistributed(address indexed victim, uint256 amount);
    event StateChanged(ContractState newState);

    function donate(uint256 amount) external;
    function registerAsVictim(bytes calldata zkProof) external;
    function withdrawFunds() external;
    function getState() external view returns (ContractState);
    function getTotalFunds() external view returns (uint256);
    function getDonorCount() external view returns (uint256);
    function getVictimCount() external view returns (uint256);
    function getLocationDetails() external view returns (LocationDetails.Location memory);
}
