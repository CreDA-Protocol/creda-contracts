// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ICErc20 {
  function decimals() external returns (uint8);

  function underlying() external returns (address);

  function balanceOf(address user) external view returns (uint);

  function borrowBalanceCurrent(address account) external returns (uint);

  function borrowBalanceStored(address account) external view returns (uint);

  function borrow(uint borrowAmount) external returns (uint);

  function repayBorrow(uint repayAmount) external returns (uint);
}
