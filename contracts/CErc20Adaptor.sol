// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '../interfaces/ICErc20.sol';
import '../interfaces/ICEther.sol';
import '../interfaces/IWETH.sol';


contract CErc20Adaptor is ICErc20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ICEther public cEther;
    IWETH public wETH;
    address public iBank;

    modifier onlyIBank {
        require(msg.sender == iBank, "Not iBank");
        _;
    }
    
    constructor(address _cEther, address _wETH, address _iBank) public {
        cEther = ICEther(_cEther);
        wETH = IWETH(_wETH);
        iBank = _iBank;
    }

    function decimals() external override returns (uint8) {
        return 18;
    }

    function underlying() external override returns (address) {
        return address(0);
    }

    function balanceOf(address account) external override view returns (uint) {
        if (account == iBank) {
            return cEther.balanceOf(address(this));
        }
        return cEther.balanceOf(account);
    }

    function borrowBalanceCurrent(address account) external override returns (uint) {
        if (account == iBank) {
            return cEther.borrowBalanceCurrent(address(this));
        }
        return cEther.borrowBalanceCurrent(account);
    }

    function borrowBalanceStored(address account) external view override returns (uint) {
        if (account == iBank) {
            return cEther.borrowBalanceStored(address(this));
        }     
        return cEther.borrowBalanceStored(account);
    }

    function borrow(uint borrowAmount) external onlyIBank override returns (uint) {
        require(borrowAmount > 0, "borrow amount is zero");

        uint256 borrowResult = cEther.borrow(borrowAmount);
        require(borrowResult == 0, "Bad borrow");
        wETH.deposit{value: borrowAmount}();
        wETH.transfer(iBank, borrowAmount);
        return borrowResult;
    }

    function repayBorrow(uint repayAmount) external onlyIBank override returns (uint) {
        require(repayAmount > 0, "repay amount is zero");

        IERC20(address(wETH)).safeTransferFrom(msg.sender, address(this), repayAmount);
        wETH.withdraw(repayAmount);
        uint256 balanceBeforeRepay = address(this).balance;
        cEther.repayBorrow{value: repayAmount};
        uint256 balanceAfterRepay = address(this).balance;
        uint256 returnAmount = balanceBeforeRepay.sub(balanceAfterRepay);
        if (returnAmount > 0) {
            wETH.deposit{value: returnAmount}();
            wETH.transfer(iBank, returnAmount);
        }
        return 0;
    }

    /// @dev Withdraw the reward to the bank.
    function withdrawReward(address rewardToken) external {
        uint balance = IERC20(rewardToken).balanceOf(address(this));
        if (balance > 0) {
           IERC20(rewardToken).safeTransfer(iBank, balance);
        }
    }

      /// @dev Fallback function. Can only receive ETH from cErc20 or wETH contract.
    receive() external payable {
        require(msg.sender == address(cEther) || msg.sender == address(wETH), 'ETH must come from WETH');
    }
}
