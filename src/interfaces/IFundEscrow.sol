// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;    
interface IFundEscrow {
    event FundsDeposited(address indexed sender, uint256 amount);
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    event FundsAllocated(address indexed disasterRelief, uint256 amount);

    function deposit() external payable;
    function allocate(address payable disasterRelief, uint256 amount) external;
    function withdraw() external ;
    function getTotalFunds() external view returns (uint256);

    
}