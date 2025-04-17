// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;


import {IAnonAadhaar} from '@anon-aadhaar/contracts/interfaces/IAnonAadhaar.sol';

contract ZKVerifier is IAnonAadhaar{
    //store nullifier=>campaignId => bool
    mapping(uint256 => mapping(uint256 => bool)) public nullifierToCampaignId;

    function verifyAnonAadhaarProof(
        uint nullifierSeed,
        uint nullifier,
        uint timestamp,
        uint signal, //campaig id
        uint[4] memory revealArray,
        uint[8] memory groth16Proof
    ) external view returns (bool){
        require(nullifierSeed == uint256(1234),"Invalid nullifier seed");
        require(!nullifierToCampaignId[nullifier][signal],"User already registered for this campaign");
        return true;
    }

    function registerNullifier(uint256 nullifier, uint256 campaignId) external {
        nullifierToCampaignId[nullifier][campaignId] = true;
    }
    function isNullifierRegistered(uint256 nullifier, uint256 campaignId) external view returns (bool){
        return nullifierToCampaignId[nullifier][campaignId];
    }
}