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
    address public immutable USDC;
    
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
    uint256 public distributedFunds;  // Track funds that have already been distributed
    uint256 public amountPerVictim;   // Store the calculated amount per victim
    
    DisasterDonorBadge public donorBadge;
    IZKVerifier public zkVerifier;
    
    mapping(address => bool) public donors;
    mapping(address => bool) public victims;
    mapping(address => bool) public hasWithdrawn;
    
    constructor(
        string memory _disasterName,
        string memory _area,
        uint256 _donationPeriod,
        uint256 _registrationPeriod,
        uint256 _waitingPeriod,
        uint256 _distributionPeriod,
        uint256 _initialFunds,
        address _donorBadge,
        address _zkVerifier,
        address _usdc
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
        USDC = _usdc;
    }
    
    // Automatically update state as needed before any external function is executed
    modifier autoUpdateState() {
        updateState();
        _;
    }
    
    function donate(uint256 amount) external override autoUpdateState {
        require(state == ContractState.Donation, "Campaign status mismatch");
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
    
    function registerAsVictim(bytes calldata zkProof) external override autoUpdateState {
        require(state == ContractState.Registration, "Registrations Not started");
        require(!victims[msg.sender], "Already registered");
        //require(zkVerifier.verifyAadhar(zkProof) || zkVerifier.verifyAnon(zkProof), "Invalid proof");
        
        victims[msg.sender] = true;
        totalVictims++;
        
        emit VictimRegistered(msg.sender);
    }
    
    function calculateAmountPerVictim() internal {
        // Calculate this only once when transitioning to Distribution state
        if (amountPerVictim == 0 && totalVictims > 0) {
            // Ensure we don't distribute more than available funds
            amountPerVictim = totalFunds / totalVictims;
        }
    }
    
    function withdrawFunds() external override autoUpdateState {
        require(state == ContractState.Distribution, "Campaign status mismatch");
        require(victims[msg.sender], "Not a registered victim");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        
        // Calculate amount per victim if not already calculated
        calculateAmountPerVictim();
        
        // Safety check - ensure we have enough funds
        uint256 actualBalance = IERC20(USDC).balanceOf(address(this));
        uint256 amount = amountPerVictim;
        
        // If we somehow don't have enough funds, adjust the amount
        if (amount > actualBalance) {
            amount = actualBalance;
        }
        
        hasWithdrawn[msg.sender] = true;
        distributedFunds += amount;
        
        IERC20(USDC).safeTransfer(msg.sender, amount);
        
        emit FundsDistributed(msg.sender, amount);
    }
    
    // This function can still be called directly, but now it's also called 
    // automatically via the autoUpdateState modifier
    function updateState() public {
        if (state == ContractState.Donation && block.timestamp >= donationEndTime) {
            state = ContractState.Registration;
            emit StateChanged(state);
        }
        if (state == ContractState.Registration && block.timestamp >= registrationEndTime) {
            state = ContractState.Waiting;
            emit StateChanged(state);
        }
        if (state == ContractState.Waiting && block.timestamp >= waitingEndTime) {
            state = ContractState.Distribution;
            // Calculate the amount per victim when entering distribution state
            calculateAmountPerVictim();
            emit StateChanged(state);
        }
        if (state == ContractState.Distribution && block.timestamp >= distributionEndTime) {
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