// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IDisasterReliefFactory} from "./interfaces/IDisasterReliefFactory.sol";
import {DisasterRelief} from "./DisasterRelief.sol";
import{IDAOGovernance} from "./interfaces/IDAOGovernance.sol";
import {DisasterDonorBadge} from "./DisasterDonorBadge.sol";
import {IFundEscrow} from "./interfaces/IFundEscrow.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DisasterReliefFactory is IDisasterReliefFactory {
    using SafeERC20 for IERC20;
    
    address public immutable USDC;
    
    IDAOGovernance public daoGov;
    address public zkVerifier;
    address public owner;
    DisasterDonorBadge public donorBadge;
    
    mapping(address => bool) public isDisasterRelief;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor(address _daoGov, address _zkVerifier,address _usdc,address _donorBadge) {
        owner = msg.sender;
        daoGov= IDAOGovernance(_daoGov);
        zkVerifier = _zkVerifier;
        USDC=_usdc;
        donorBadge=DisasterDonorBadge(_donorBadge);
    }
    
    function deployDisasterRelief(
        string memory disasterName,
        string memory area,
        uint256 donationPeriod,
        uint256 registrationPeriod,
        uint256 waitingPeriod,
        uint256 distributionPeriod,
        uint256 initialFunds
    ) external override returns (address) {
        require(msg.sender == address(daoGov), "Only fund escrow can deploy");
        
        
        DisasterRelief newRelief = new DisasterRelief(
            disasterName,
            area,
            donationPeriod,
            registrationPeriod,
            waitingPeriod,
            distributionPeriod,
            initialFunds,
            address(donorBadge),
            zkVerifier
        );
        
        isDisasterRelief[address(newRelief)] = true;
        
        emit DisasterReliefDeployed(address(newRelief), disasterName, initialFunds);
        return address(newRelief);
    }
    function setDAOGovernance(address _daoGov) external onlyOwner {
        daoGov = IDAOGovernance(_daoGov);
    }
    
    function setZKVerifier(address _zkVerifier) external onlyOwner {
        zkVerifier = _zkVerifier;
    }
}