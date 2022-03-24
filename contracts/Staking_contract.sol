// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is ERC20, Ownable {


    address _owner;
    uint totalSupplyy = 1000 * 10 ** 18;

    mapping (address => uint) balanceOff;
    mapping (address => uint) rewardDueDate;
    mapping (address => uint) locked;
    //using SafeMath for unit256;

    constructor() ERC20("MaaziCoin", "MCN") {
        _owner = msg.sender;
        balanceOff[msg.sender] += totalSupplyy;
    }

    address[] internal stakeholders;

    // Boolean function to check if the address entered is a stakeholder already
    function isStakeholder(address _address)
       public
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }

    // function to add Stakeholder addresses
    function addStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }

   uint tokenToEthRate  = 1000;

   function modifyTokenBuyPrice(uint _newPrice) private onlyOwner returns (bool){
       require(_newPrice > 0, "Exchange rate cannot be zero");
       require(tokenToEthRate != _newPrice, "New Exchange rate must differ from old/Previous rate");

       tokenToEthRate = _newPrice;
       return true;
   }

   function stakeToken(address _stakeHolderAddress, uint _amountToStake) public {
       require(_amountToStake <= balanceOff[_stakeHolderAddress], "Can't stake an amount you don't have");

       locked[_stakeHolderAddress] += _amountToStake;
       balanceOff[_stakeHolderAddress] -= _amountToStake;
       rewardDueDate[_stakeHolderAddress] = block.timestamp + 7 days;
       addStakeholder(_stakeHolderAddress);
   }

   function claimReward(address _stakeAddress) public {
       (bool _isStakeholder, ) = isStakeholder(_stakeAddress);
       require(_isStakeholder == true, "Address must be a stakeholder first");
       if(block.timestamp >= rewardDueDate[_stakeAddress]){
           rewardDueDate[_stakeAddress] = block.timestamp + 7 days;
           }
        balanceOff[_stakeAddress] += locked[_stakeAddress] + (locked[_stakeAddress] * 1/100);
       
   }

    function buyToken(address _receiver) external payable {
        require(msg.value > 0, "You cannot mint MCN with zero ETH");

        uint256 _amount = msg.value * tokenToEthRate / 10 ** decimals();
        totalSupplyy += _amount;
        balanceOff[_receiver] += _amount;
        
    }
