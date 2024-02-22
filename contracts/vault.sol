// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error NOT_BENEFICIARY();
error AMOUNT_GREATER_THAN_BALANCE();
error NOT_TIME_TO_WITHDRAW();

contract Vault{
    struct grant {
        address donor;
        address payable beneficiary;
        uint amount;
        uint unlocktime;
    }

    mapping(address => grant) vault;
    
    event GrantOfferedSuccessfully(address _donor, uint _amount);
    event GrantWithdrawn (address _beneficiary, uint _amount);

    function Offergrant(address payable _beneficiary /*uint _unlocktimeInYears*/) external payable {
        require (msg.sender != address(0));

        grant storage Dnt = vault[msg.sender];
        Dnt.beneficiary = _beneficiary;
        Dnt.amount += msg.value;
        Dnt.unlocktime = block.timestamp + 30;
        Dnt.donor = msg.sender;

        Dnt = vault[msg.sender];

        emit GrantOfferedSuccessfully(msg.sender, msg.value);

    }

    function getGrant() external view returns (grant memory){

        return vault[msg.sender];
    }

    function withdrawGrant (address _donor, uint _amount) external {
        
        require (msg.sender != address(0));

        if(msg.sender != vault[_donor].beneficiary){
            revert NOT_BENEFICIARY();
        }

        if(_amount > vault[_donor].amount){
            revert AMOUNT_GREATER_THAN_BALANCE();
        }
                
        if(block.timestamp < vault[_donor].unlocktime){
            revert NOT_TIME_TO_WITHDRAW();
        }

        grant storage tnx = vault[_donor];

        uint withd = tnx.amount;

        vault[_donor].beneficiary.transfer(withd);

        tnx.amount -= withd;

        vault[_donor] = tnx;

        emit GrantWithdrawn(msg.sender, _amount);

    }

    receive() external payable { }

    fallback() external payable { }
}