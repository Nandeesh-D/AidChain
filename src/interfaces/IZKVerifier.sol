// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IZKVerifier {
    function verifyAadhar(bytes calldata proof) external view returns (bool);
    function verifyAnon(bytes calldata proof) external view returns (bool);
}
