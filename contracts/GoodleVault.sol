// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.4;

import {UUPSUpgradeable, AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract GoodleVault is Initializable, UUPSUpgradeable {
    using SafeMath for uint256;
    address public owner;
    address private teamMultiSig;
    uint256 public currentMonthCollection;
    uint256 public totalCollection;
    uint256 public totalDistributed;

    mapping(address => uint256) public canClaim;

    modifier onlyOwner() {
        require(msg.sender == owner, "ERR: AUTH FAILED");
        _;
    }

    event LogClaim(address indexed User, uint256 Amount);
    event LogDistribute(address[] Users, uint256[] Amounts, uint256 teamShare);

    //==========// Initializer //==========//

    function initialize(address _teamMultiSig) public initializer {
        owner = msg.sender;
        teamMultiSig = _teamMultiSig;
    }

    //==========// External Functions //==========//

    receive() external payable {
        currentMonthCollection += msg.value;
        totalCollection += msg.value;
    }

    function setTeamMultiSig(address _teamMultiSig) external onlyOwner {
        teamMultiSig = _teamMultiSig;
    }

    function checkVaultBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function claim() public payable {
        uint256 amt = canClaim[msg.sender];
        require(amt > 0, "ERR : ZERO CLAIM");
        require(amt <= checkVaultBalance(), "ERR : INSUFFICIENT BAL");
        bool sent = payable(msg.sender).send(amt);
        require(sent, "ERR : SEND FAILED");
        canClaim[msg.sender] = 0;
        emit LogClaim(msg.sender, amt);
    }

    function distribute(
        address[] memory _users,
        uint256[] memory _amounts,
        uint256 _teamAmount
    ) external onlyOwner {
        uint256 totalAmount = _teamAmount;
        require(_users.length == _amounts.length, "ERR : LEN MISS-MATCH");
        for (uint256 i = 0; i < _users.length; i++) {
            totalAmount += _amounts[i];
            canClaim[_users[i]] += (_amounts[i]);
        }
        require(totalAmount <= checkVaultBalance(), "ERR : INVALID ALLOC");
        bool sent = payable(teamMultiSig).send(_teamAmount);
        require(sent, "ERR : SEND FAILED");
        currentMonthCollection = 0;
        totalDistributed += totalAmount.sub(_teamAmount);
        emit LogDistribute(_users, _amounts, _teamAmount);
    }

    function upgradeTo(address newImplementation_)
        external
        virtual
        override
        onlyOwner
    {
        _authorizeUpgrade(newImplementation_);
        _upgradeTo(newImplementation_);
    }

    //==========// Internal Functions //==========//

    function _authorizeUpgrade(address newImplementation_)
        internal
        virtual
        override
        onlyOwner
    {
        require(
            AddressUpgradeable.isContract(newImplementation_),
            "ERR : NOT CONTRACT"
        );
    }
}
