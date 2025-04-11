// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import{Test,console} from "forge-std/Test.sol";
import{MockUSDC} from "../test/MockUSDC.sol";
import{DAOGovernance,IDAOGovernance} from "../src/DAOGovernance.sol";
import{DAOGovernanceDeployer} from "../script/DAOGovernance.s.sol";
contract DAOConstanst is Test{
    address admin=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; //anvil default address
        //dao members
    address member1=address(1);
    address member2=address(2);
    address member3=address(3);
    address member4=address(4);
    address member5=address(5);

    address mockUsdc=0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;
    IDAOGovernance daoGovernance;
    function setUp() public{
        vm.prank(admin);
        DAOGovernanceDeployer daoGovernanceDeployer=new DAOGovernanceDeployer();
        (address _daoGovernance,address _disasterReliefFactory,address _fundEscrow)=daoGovernanceDeployer.run();
        daoGovernance=IDAOGovernance(_daoGovernance);
        vm.prank(admin);
        daoGovernance.setDisasterReliefFactory(address(_disasterReliefFactory));
        vm.prank(admin);
        daoGovernance.setFundEscrow(address(_fundEscrow));
       
    }

    modifier MembersAdded(){
        vm.startPrank(admin);
        daoGovernance.addDAOMember(member1);
        daoGovernance.addDAOMember(member2);
        daoGovernance.addDAOMember(member3);
        daoGovernance.addDAOMember(member4);
        daoGovernance.addDAOMember(member5);
        vm.stopPrank();
        _;
    }
    
    modifier ProposalCreated(){
        vm.startPrank(member1);
        uint256 proposalId=daoGovernance.createProposal("Hudud Cyclone","Chennai",6*24*60*60,1000,"cyclone.jpg");
        assert(proposalId==1);
        assert(daoGovernance.getProposal(proposalId).id==1);
        //assert(bytes(daoGovernance.getProposal(proposalId).disasterName)==bytes("Hudud Cyclone"));
        assert(daoGovernance.getProposal(proposalId).duration==6*24*60*60);
        assert(daoGovernance.getProposal(proposalId).fundsRequested==1000);
        assert(daoGovernance.getProposal(proposalId).proposer==member1);
        vm.stopPrank();
        _;
    }
    
    function test_addMembers() public{
        vm.startPrank(admin);
        daoGovernance.addDAOMember(member1);
        daoGovernance.addDAOMember(member2);
        daoGovernance.addDAOMember(member3);
        daoGovernance.addDAOMember(member4);
        daoGovernance.addDAOMember(member5);
        vm.stopPrank();
    }
 
    function test_CreateProposal() public{
        test_addMembers();
        vm.startPrank(member1);
        uint256 proposalId=daoGovernance.createProposal("Hudud Cyclone","Chennai",6*24*60*60,1000,"cyclone.jpg");
        assert(proposalId==1);
        assert(daoGovernance.getProposal(proposalId).id==1);
        //assert(bytes(daoGovernance.getProposal(proposalId).disasterName)==bytes("Hudud Cyclone"));
        assert(daoGovernance.getProposal(proposalId).duration==6*24*60*60);
        assert(daoGovernance.getProposal(proposalId).fundsRequested==1000);
        assert(daoGovernance.getProposal(proposalId).proposer==member1);
        vm.stopPrank();
    }

    function test_VoteSuccess() public MembersAdded ProposalCreated{
        vm.startPrank(member2);
        daoGovernance.vote(1,true);
        assert(daoGovernance.getProposal(1).forVotes==1);
        assert(daoGovernance.hasVoted(1,member2)==true);
        vm.stopPrank();
    }
    
    function test_proposalPassed() public MembersAdded ProposalCreated{
        //6 members in DAO atleast 4 members need to be voted
        vm.prank(member2);
        daoGovernance.vote(1,true);
        vm.prank(member3);
        daoGovernance.vote(1,true);
        vm.prank(member4);
        daoGovernance.vote(1,true);
        vm.prank(member5);
        daoGovernance.vote(1,true);
        assert(daoGovernance.getProposal(1).forVotes==4); 
        console.log("passed");
        console.log("daoGov fundEscrow",daoGovernance.fundEscrow1());
        assert(daoGovernance.getProposal(1).state==IDAOGovernance.ProposalState.Passed);
        console.log("passed");
    }
}