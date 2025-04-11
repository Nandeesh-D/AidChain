// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {INFTBadge} from "./interfaces/INFTBadge.sol";

contract GeneralDonorBadge is ERC721, INFTBadge {
    uint256 private _nextTokenId;
    address public owner;
    string private _baseTokenURI;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() ERC721("GeneralDonorBadge", "GDB") {
        owner = msg.sender;
    }
    
    function mint(address to) external override returns (uint256) {
        require(msg.sender == owner, "Not authorized");
        
        uint256 tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);
        
        emit BadgeMinted(to, tokenId);
        return tokenId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    
    function totalSupply() external view override returns (uint256) {
        return _nextTokenId;
    }
}