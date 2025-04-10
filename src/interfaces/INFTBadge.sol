// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;


interface INFTBadge {
    enum BadgeType { GeneralDonor, DisasterSpecificDonor }
    
    event BadgeMinted(address indexed recipient, uint256 tokenId, BadgeType badgeType);
    
    function mintBadge(address recipient, BadgeType badgeType, string memory disasterId) external returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}