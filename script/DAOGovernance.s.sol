// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import{Script,console} from "forge-std/Script.sol";
import {DAOGovernance,IDAOGovernance} from "../src/DAOGovernance.sol";
import{DisasterReliefFactory,IDisasterReliefFactory} from "../src/DisasterReliefFactory.sol";
import{DisasterDonorBadge,INFTBadge} from "../src/DisasterDonorBadge.sol";
import{GeneralDonorBadge,INFTBadge} from "../src/GeneralDonorBadge.sol";
import{FundEscrow,IFundEscrow} from "../src/FundEscrow.sol";
import{MockUSDC} from "../test/MockUSDC.sol";
contract DAOGovernanceDeployer is Script{
    function run() external returns(address daoGovernance,address disasterReliefFactory,address fundEscrow){
        vm.startBroadcast();
        address admin=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; //anvil default address
        IDAOGovernance _daoGovernance = new DAOGovernance(admin);
        console.log("DAOGovernance address",address(_daoGovernance));
        console.log("DAO admin addess",_daoGovernance.isAdmin(admin));
        IDisasterReliefFactory _disasterReliefFactory = new DisasterReliefFactory(address(_daoGovernance),0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512);
        console.log("DisasterReliefFactory address",address(_disasterReliefFactory));
        
        //deploy general badge
        INFTBadge _generalDonorBadge = new GeneralDonorBadge();
        console.log("GeneralDonorBadge address",address(_generalDonorBadge));

        //deploy donation badge
        INFTBadge _disasterDonorBadge = new DisasterDonorBadge();
        console.log("DisasterDonorBadge address",address(_disasterDonorBadge));

        //deploy mock usdc
        MockUSDC _mockUSDC = new MockUSDC();
        //deploy fund escrow
        
        IFundEscrow _fundEscrow = new FundEscrow(address(_disasterReliefFactory),address(_generalDonorBadge),address(_daoGovernance),address(_mockUSDC));
        
        console.log("FundEscrow address",address(_fundEscrow));
        
        vm.stopBroadcast();
        return (address(_daoGovernance),address(_disasterReliefFactory),address(_fundEscrow));
    }
}