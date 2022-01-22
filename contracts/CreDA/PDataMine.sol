// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../owner/AdminRole.sol";
import "../interfaces/ICredaOracle.sol";

contract PDataMine is AdminRole {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    address public creda;
    address public creditOracle;
    uint256 public starttime;
    uint256 public totolClaimedCreda;
    uint256 public checkHalveCreda = 15 * 10**7 * 10**18;
    uint8 public ratio;
    mapping(address => bool) public initialAccount;
    mapping(address => uint256) public creditPoint;
    mapping(address => uint256) public credaClaimed;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, address token, uint256 amount);
    event Withdrawn(address indexed user, address token, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event creditUpdated(address indexed user, bool initialAccount);
    event RewardHalve(uint256 amount);
    constructor(
        address token_,
        address creditOracle_,
        uint256 starttime_        
    ) {
        creda = token_;
        creditOracle = creditOracle_;
        starttime = starttime_;
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, "Not Started");
        _;
    }

    modifier checkhalve() {
        if (totolClaimedCreda >= checkHalveCreda) {
            ratio = ratio / 2;
            totolClaimedCreda = totolClaimedCreda - checkhalveCreda;
            chechhalveCreda = checkhalveCreda/2;
            emit RewardHalve(checkhalveCreda);
        }
        _;
    }

    function claimable(address account) public view returns (uint256) {
        if (credaClaimed[account] >= creditPoint[account]* ratio / 100) {
            return 0;
        }
            return
            creditPoint[account]* ratio / 100 - credaClaimed[account];
    }

    function getReward() public nextCreditUpdate(msg.sender) checkStart checkhalve {
        nextCreditUpdate(msg.sender);
        uint256 reward = claimable(msg.sender);
        require(reward > 0, "No Claimable CREDA Token");
        credaClaimed[account] += reward;
        totolClaimedCreda += reward;
        IERC20(creda).safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
        } 

    function updateStartTime(uint256 starttime_) external onlyAdmin {
        starttime = starttime_;
    }

    function creditUpdate() public {
        if (initialAccount[msg.sender] == false) {
                initialCreditUpdate();
                return;
            }
                nextCreditUpdate();
        }

    function initialCreditUpdate() private {
        ICredaOracle(creditOracle).getCredit(msg.sender);
        initialAccount[msg.sender] = true;
        }

    function nextCreditUpdate() private updateReward(msg.sender){
        creditPoint[msg.sender] = ICredaOracle(creditOracle).creditOf(msg.sender)  * 10 ** 18;
        ICredaOracle(creditOracle).getCredit(msg.sender);
        emit creditUpdated(msg.sender, initialAccount[msg.sender]);
    }

    function ApproveCreda(address creditOracle_, uint256 amount) external onlyAdmin {
            IERC20(creda).safeApprove(creditOracle_, amount);
    }
  
    function SetCreDA(address token_) external onlyAdmin {
        creda = token_;
    }

    function SetCreditOracle(address creditOracle_) external onlyAdmin {
        creditOracle = creditOracle_;
    }

}
