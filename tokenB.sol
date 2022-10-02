// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

library SafeMathTokenB { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a); //error handling condition
      return a - b;  //To Avoid Overflows
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }
}

contract tokenB{

    string public constant name = "B";  // name of token
    string public constant symbol = "B"; // symbol of token
    uint8 public constant decimals = 18; // token works as ether
    
    // event to track token transactions 
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    // check if sender is owner or not
    modifier contractOwner  {
        require (msg.sender == Owner);
        _;
    }

    // map for how much token acquired by the sender
    mapping(address => uint256) amount;
    uint256 _tSupply; // total suppy of token
    address Owner; //Owner of Contract

    using SafeMathTokenB for uint256; // use matha

    // Set amount of token while deployment of contract
    constructor()
    { 
        amount[msg.sender] = 100000000000000000 ;  // Defualt tokens to Owner account
        _tSupply = 100000000000000000 ;
        Owner = msg.sender;
    }

    // get total supply of token B
    function totalSupply() public view returns (uint256) 
    {
	    return _tSupply;
    }
    
    // get Balance of particular Account 
    function balanceOfAccount(address ipAddress) public view returns (uint) 
    {
        return amount[ipAddress];
    }

    // to transfer token from any account to receiver address
    function transfer(address ReceiverAddress, uint numberOfTokens) public returns (bool) 
    {
        require(numberOfTokens <= amount[msg.sender], "Not enough Balance"); // check balance of sender

        amount[msg.sender] = amount[msg.sender].sub(numberOfTokens); // Subtract tokens from sender
        amount[ReceiverAddress] = amount[ReceiverAddress].add(numberOfTokens); // add tokens to receiver

        emit Transfer(msg.sender, ReceiverAddress, numberOfTokens); // logging values

        return true;
    }

    // To Transfer token from Owner account to receiver address
    function transferFrom(address OwnerAddress, address ReceiverAddress, uint numberOfTokens) public returns (bool) 
    {
        require(numberOfTokens > 0,"tokens should be greater than 0"); // check tokens are valid or not
        require(numberOfTokens <= amount[OwnerAddress]);   // check for sufficient is in account

        amount[OwnerAddress] = amount[OwnerAddress].sub(numberOfTokens); // subtract token from owner
        amount[ReceiverAddress] = amount[ReceiverAddress].add(numberOfTokens); // add token to receiver

        emit Transfer(OwnerAddress, ReceiverAddress, numberOfTokens); // logging values 

        return true;
    }

    // For increase total supply of token B
    function newTokenB(uint256 numberOfTokens) public contractOwner 
    {
        require(numberOfTokens > 0, "tokens is not more than 0"); // check for sufficient tokens

        amount[msg.sender] = amount[msg.sender].add(numberOfTokens); // add given number tokens to sender account ( Owner account )
        _tSupply = _tSupply.add(numberOfTokens); // increase total supply

        emit Transfer(address(0),msg.sender,numberOfTokens); // logging values
    }

    // For decrease total supply of token B
    function decreaseTokenB(uint256 numberOfTokens) public contractOwner 
    {
        require(numberOfTokens <= amount[msg.sender],"Not sufficient tokens to burn"); // chech for enough token
        require(numberOfTokens > 0, "tokens is not more than 0"); // check given token is valid or not

        amount[msg.sender] = amount[msg.sender].sub(numberOfTokens); // substract token from sender ( Owner Account )
        _tSupply = _tSupply.sub(numberOfTokens); // decrease total supply

        emit Transfer(msg.sender,address(0),numberOfTokens); // logging value
    }
}