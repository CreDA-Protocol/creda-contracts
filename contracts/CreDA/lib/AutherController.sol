// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
contract AutherController is OwnableUpgradeable {
    mapping (address => bool) private _authorizedCaller;
    mapping (address => bool) private _authorizedNodes;
    modifier onlyAuthorizedCaller() {
        require(msg.sender == owner() || _authorizedCaller[msg.sender],"Not an authorized caller");
        _;
    }
    function setAuthorizedtCaller(address caller) onlyOwner public  {
        _authorizedCaller[caller] = true;
    }
    function removeAuthorizedCaller(address caller) onlyOwner public {
        _authorizedCaller[caller] = false;
    }
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