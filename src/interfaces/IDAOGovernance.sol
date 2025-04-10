// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDAOGovernance {
    enum ProposalState {  Active, Passed, Rejected }
    
    struct Proposal {
        uint256 id;
        address proposer;
        string disasterName;
        string area;
        uint256 duration;
        uint256 fundsRequested;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        ProposalState state;
    }

    event ProposalCreated(uint256 proposalId, string disasterName, string area, uint256 duration, uint256 fundAmount);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId, address disasterReliefAddress);

    
    function createProposal(
        string memory disasterName,
        string memory area,
        uint256 duration,
        uint256 fundsRequested
    ) external returns (uint256);
    
    function vote(uint256 proposalId, bool support) external;
    
    function getProposal(uint256 proposalId) external view returns (Proposal memory);
    
    function hasVoted(uint256 proposalId, address voter) external view returns (bool);

    //added extra
    function setDisasterReliefFactory(address factory) external ;
    
    function addDAOMember(address _member) external;
    
    function removeDAOMember(address _member) external;

    function proposalCount() external view returns (uint256);

    function memberCount() external view returns (uint256);

    function requiredVotingPercentage() external view returns (uint256);
}