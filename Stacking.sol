// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

// import contract of tokens A and B
import "./tokenA.sol";
import "./tokenB.sol";


contract Stacking
{
    tokenA tA;
    tokenB tB;
    
    constructor(address tknA, address tknB) {
        tA = tokenA(tknA);
        tB = tokenB(tknB);
    }

    // mapping for storing staking balances
    mapping (address => uint256) public stackingBal; // store the balances of which is stacked by the person
    address [] public stackerRec; // address of the person

    mapping (address => bool) public stacked; // check for person's stacking status

    mapping (address => uint256) public conBal; // balances of contract

    mapping (address => uint256) public timeDuration; // stacking duration

    
    // function is use for stack the token for particular time duraction
    function stackTkn(uint256 numberOfTokenForStacking, uint256 day) public returns (bool) 
    {
        // check for requier condition to execute the function
        require(numberOfTokenForStacking > 0,"tokens should be greater than 0");
        require(day > 0,"time duraction must be greater then 0"); 

        // transfer token from sender to contract
        tA.transferFrom(msg.sender,address(this),numberOfTokenForStacking);

        // update stcking balance of the contract
        stackingBal[msg.sender] = stackingBal[msg.sender] + numberOfTokenForStacking;
        conBal[address(this)] = conBal[address(this)] + numberOfTokenForStacking;

        // calculate the days from number of blocks ( 1 hour = 240 blocks )
        day = (block.number+((day *24) * 240)); 
        timeDuration[msg.sender] = day;

        // Add stacker to record
        if(!stacked[msg.sender])
        {
            stacked[msg.sender] = true;
            stackerRec.push(msg.sender);
        }

        return true;
    }

    // retrive balance of contract
    function contractBalance()public view returns (uint256){
        return conBal[address(this)];
    }

    // retrive balance of Token A
    function balanceOfTokenA(address _address) public view returns (uint256){
        return tA.balanceOfAccount(_address);
    }

    // to check time is over or not
    modifier beforeTimeDurationEnd{
        require(block.number == timeDuration[msg.sender], "Staking Period not over..");
        _;
    }

    // To check stacker or not
    modifier checkStacker{
        require(stacked[msg.sender]==true,"Not Staker..");
        _;
    }

    // This is a main logic of unstack the all stacking amount which is stacked by the stacker and they also receive the rewards..
    function getStackedTokenAndRewards() public beforeTimeDurationEnd checkStacker returns (bool)
    {
        address recipient = msg.sender; // retrive address of stacker
        uint256 tokens = stackingBal[msg.sender]; // retrive token stacked by stacker

        tA.transferFrom(address(this),recipient,tokens); // unstack all token of stacker
        stackingBal[msg.sender] = 0; // set stacking balance of staker to Zero.

        stacked[msg.sender] = false; // remove stacker from stacker list

        uint256 rewards = 0;

        // calculate the rewards based of given conditions.
        if(timeDuration[msg.sender] > 1 && timeDuration[msg.sender] < 15)
        {
            rewards = (tokens * 10) / 100;
        }
        else if(timeDuration[msg.sender] >15 && timeDuration[msg.sender] <30)
        {
            rewards = (tokens * 15) / 100;
        }
        else if(timeDuration[msg.sender] > 30 && timeDuration[msg.sender] < 45)
        {
            rewards = (tokens * 20) / 100;
        }

        // If reward is greater then 0 then we transfer token B to staker
        if(rewards > 0)
        {
            tB.transfer(recipient,rewards);
        }      
        
        return true;
    }
}