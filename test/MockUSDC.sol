// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockUSDC{
    using SafeERC20 for IERC20;

    string public constant name = "Mock USDC";
    string public constant symbol = "USDC";
    uint8 public constant decimals = 6;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    
    address public owner;
    event Transfer(address indexed from, address indexed to, uint256 value);
    

    constructor() {
        owner = msg.sender;
        _mint(msg.sender, 100 * 10 ** decimals);
    }

    // anyone can mint the tokens for testing
    function _mint(address account, uint256 amount) public {
        require(account != address(0), "Mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
}