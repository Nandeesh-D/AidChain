// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IDAOGovernance} from "./interfaces/IDAOGovernance.sol";
import{IDisasterReliefFactory} from "./interfaces/IDisasterReliefFactory.sol";


contract DAOGovernance is IDAOGovernance {
    // Roles and access control
    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isDAOMember;
    uint256 public totalMembers;
    
    // Proposal tracking
    uint256 private _nextProposalId;
    mapping(uint256 => Proposal) private _proposals;
    mapping(uint256 => mapping(address => bool)) private _hasVoted;
    
    // Governance parameters
    uint256 public votingPeriod = 2 days;
    uint256 public quorumPercentage = 60; // 60% of votes needed to pass
    
    IDisasterReliefFactory public disasterReliefFactory;
    
    // Modifiers
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Not an admin");
        _;
    }
    
    modifier onlyDAOMember() {
        require(isDAOMember[msg.sender], "Not a DAO member");
        _;
    }
    
    constructor(address admin) {
        isAdmin[admin] = true;
        isDAOMember[admin] = true;
        totalMembers = 1;
    }
    
    function setDisasterReliefFactory(address factory) external onlyAdmin {
        //only one time factory set
        if(address(disasterReliefFactory)==address(0)){
                disasterReliefFactory = IDisasterReliefFactory(factory);
        }    
    }
    
    function addDAOMember(address member) external onlyAdmin {
        if (!isDAOMember[member]) {
            isDAOMember[member] = true;
            totalMembers++;
        }
    }
    
    function removeDAOMember(address member) external onlyAdmin {
        if (isDAOMember[member]) {
            isDAOMember[member] = false;
            totalMembers--;
        }
    }
    
    function createProposal(
        string memory disasterName, 
        string memory area, 
        uint256 duration, 
        uint256 fundAmount
    ) external onlyDAOMember override returns (uint256) {
        uint256 proposalId = ++_nextProposalId;
        
        _proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            disasterName: disasterName,
            area: area,
            duration: duration,
            fundsRequested: fundAmount,
            forVotes: 0,
            againstVotes: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + votingPeriod,
            state: ProposalState.Active
        });
        
        emit ProposalCreated(proposalId, disasterName, area, duration, fundAmount);
        return proposalId;
    }
    
    function vote(uint256 proposalId, bool support) external onlyDAOMember override {
        Proposal storage proposal = _proposals[proposalId];
        require(proposal.state == ProposalState.Active, "Proposal Not Active");
        require(block.timestamp < proposal.endTime, "Voting period has ended");
        require(!_hasVoted[proposalId][msg.sender], "Already voted");
        
        _hasVoted[proposalId][msg.sender] = true;
        
        if (support) {
            proposal.forVotes++;

            if(isProposalPassed(proposalId)){
                executeProposal(proposalId);
            }
        } else {
            proposal.againstVotes++;
        }
        
        emit Voted(proposalId, msg.sender, support);
    }
    
    function executeProposal(uint256 proposalId) internal {
        Proposal storage proposal = _proposals[proposalId];
        require(proposal.state == ProposalState.Active, "Proposal does not exist");
        require(block.timestamp > proposal.endTime, "Voting period not ended");
        require(isProposalPassed(proposalId), "Proposal did not pass");
        
        proposal.state = ProposalState.Passed;
        
        // Deploy DisasterRelief contract via factory
        address disasterReliefAddress = disasterReliefFactory.deployDisasterRelief(
            proposal.disasterName,
            proposal.area,
            7 days, // donation period
            7 days, // registration period
            4 days, // waiting period
            7 days, // distribution period
            proposal.fundsRequested
        );
        
        emit ProposalExecuted(proposalId, disasterReliefAddress);
    }
    
    function isProposalPassed(uint256 proposalId) internal view returns (bool) {
        
        Proposal memory proposal = _proposals[proposalId];
        require(proposal.state == ProposalState.Active, "Proposal is Not Active");
        
        // Calculate participation and approval
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 participationRate = (totalVotes * 100) / totalMembers;
        
        // Check if quorum reached and majority voted in favor
        return participationRate >= quorumPercentage && proposal.forVotes > proposal.againstVotes;
    }

    function hasVoted(uint256 proposalId, address voter) external view returns (bool){
        return _hasVoted[proposalId][voter];
    }
    
    function getProposal(uint256 proposalId) external view override returns (Proposal memory) {
        require(_proposals[proposalId].id == 0, "Proposal does not exist");
        return _proposals[proposalId];
    }

    function proposalCount() external view returns (uint256){
        return _nextProposalId;
    }

    function memberCount() external view returns (uint256){
        return totalMembers;
    }

    function requiredVotingPercentage() external view returns (uint256){
        return quorumPercentage;
    }
}