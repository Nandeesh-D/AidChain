// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IDisasterRelief} from "./interfaces/IDisasterRelief.sol";
import {IFundEscrow} from "./interfaces/IFundEscrow.sol";
import {DisasterDonorBadge} from "./DisasterDonorBadge.sol";
import {IZKVerifier} from "./interfaces/IZKVerifier.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DisasterRelief is IDisasterRelief {
    using SafeERC20 for IERC20;
    
    // Base Sepolia USDC address (testnet)
    address public immutable USDC = 0x34A1D3fff3958843C43aD80F30b94c510645C316;
    
    string public disasterName;
    string public area;

    ContractState public state;
    
    uint256 public donationEndTime;
    uint256 public registrationEndTime;
    uint256 public waitingEndTime;
    uint256 public distributionEndTime;
    
    uint256 public totalFunds;
    uint256 public totalDonors;
    uint256 public totalVictims;
    
    DisasterDonorBadge public donorBadge;
    IZKVerifier public zkVerifier;
    
    mapping(address => bool) public donors;
    mapping(address => bool) public victims;
    mapping(address => bool) public hasWithdrawn;
    
    modifier onlyInState(ContractState requiredState) {
        require(state == requiredState, "Invalid contract state");
        _;
    }
    
    constructor(
        string memory _disasterName,
        string memory _area,
        uint256 _donationPeriod,
        uint256 _registrationPeriod,
        uint256 _waitingPeriod,
        uint256 _distributionPeriod,
        uint256 _initialFunds,
        address _donorBadge,
        address _zkVerifier
    ) {
        disasterName = _disasterName;
        area = _area;
        
        donationEndTime = block.timestamp + _donationPeriod;
        registrationEndTime = donationEndTime + _registrationPeriod;
        waitingEndTime = registrationEndTime + _waitingPeriod;
        distributionEndTime = waitingEndTime + _distributionPeriod;
        
        state = ContractState.Donation;
        totalFunds = _initialFunds;
        
        donorBadge = DisasterDonorBadge(_donorBadge);
        zkVerifier = IZKVerifier(_zkVerifier);
    }
    
    function donate(uint256 amount) external override onlyInState(ContractState.Donation) {
        require(block.timestamp < donationEndTime, "Donation period ended");
        require(amount > 0, "Amount must be positive");
        
        IERC20(USDC).safeTransferFrom(msg.sender, address(this), amount);
        totalFunds += amount;
        
        if (!donors[msg.sender]) {
            donors[msg.sender] = true;
            totalDonors++;
            donorBadge.mint(msg.sender);
        }
        
        emit DonationReceived(msg.sender, amount);
    }
    
    function registerAsVictim(bytes calldata zkProof) external override onlyInState(ContractState.Registration) {
        require(block.timestamp < registrationEndTime, "Registration period ended");
        require(!victims[msg.sender], "Already registered");
        require(zkVerifier.verifyAadhar(zkProof) || zkVerifier.verifyAnon(zkProof), "Invalid proof");
        
        victims[msg.sender] = true;
        totalVictims++;
        
        emit VictimRegistered(msg.sender);
    }
    
    function withdrawFunds() external override onlyInState(ContractState.Distribution) {
        require(victims[msg.sender], "Not a registered victim");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        require(block.timestamp < distributionEndTime, "Distribution period ended");
        
        uint256 amount = totalFunds / totalVictims;
        hasWithdrawn[msg.sender] = true;
        
        IERC20(USDC).safeTransfer(msg.sender, amount);
        
        emit FundsDistributed(msg.sender, amount);
    }
    
    //anyone can call this
    function updateState() external {
        if (state == ContractState.Donation && block.timestamp >= donationEndTime) {
            state = ContractState.Registration;
            emit StateChanged(state);
        } else if (state == ContractState.Registration && block.timestamp >= registrationEndTime) {
            state = ContractState.Distribution;
            emit StateChanged(state);
        } else if (state == ContractState.Distribution && block.timestamp >= distributionEndTime) {
            state = ContractState.Closed;
            emit StateChanged(state);
        }
    }
    
    function getState() external view override returns (ContractState) {
        return state;
    }
    
    function getTotalFunds() external view override returns (uint256) {
        return totalFunds;
    }
    
    function getDonorCount() external view override returns (uint256) {
        return totalDonors;
    }
    
    function getVictimCount() external view override returns (uint256) {
        return totalVictims;
    }
}