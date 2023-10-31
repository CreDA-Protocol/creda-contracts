// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICredaOracle {
    function getCredit(address acount)
        external;
    function creditOf(address acount)
        external
        view
        returns (uint256 score);
    function firstBindAddress(address mainAddress) external;
    function getDidByAddress(address acount) external view returns (bytes32 did);
    function bindAddress(address mainAddress,address secondAddress) external;
    function unBindAddress(address mainAddress,address secondAddress) external;
    function isBindOf(address  mainAddress,address secondAddress) external;

}