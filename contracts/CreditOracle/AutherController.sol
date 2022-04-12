// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
contract AutherController is OwnableUpgradeable {
    mapping (address => bool) private _authorizedNodes;
    modifier onlyAuthorizedNodes() {
        require(msg.sender == owner() || _authorizedNodes[msg.sender],"Not an authorized node");
        _;
    }
    function setAuthorizedtNode(address node) onlyOwner public  {
        _authorizedNodes[node] = true;
    }
    function removeAuthorizedNode(address node) onlyOwner public {
        _authorizedNodes[node] = false;
    }
}