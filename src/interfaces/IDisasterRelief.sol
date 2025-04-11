

// interface IDisasterRelief {
//     struct Victim {
//         address payable walletAddress;
//         bool isRegistered;
//         bool hasClaimed;
//     }

//     enum Phase { Donation, Registration, Waiting, Distribution, Completed }

//     event VictimRegistered(address indexed victim, string zkProof);
//     event FundsWithdrawn(address indexed victim, uint256 amount);
//     event DonationReceived(address indexed donor, uint256 amount);
//     event PhaseChanged(Phase newPhase);

//     function donate() external payable;
//     function registerVictim(string memory zkProof) external;
//     function withdraw() external;
//     function advancePhase() external;
//     function getCurrentPhase() external view returns (Phase);
//     function getTotalFunds() external view returns (uint256);
//     function getVictimCount() external view returns (uint256);
//     function isVictimRegistered(address victim) external view returns (bool);
//     function hasVictimClaimed(address victim) external view returns (bool);
//     function getDisasterDetails() external view returns (
//         string memory name,
//         string memory area,
//         uint256 duration,
//         uint256 totalVictims
//     );
// }


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDisasterRelief {
    enum ContractState { Donation, Registration, Distribution, Closed }
    
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
}
