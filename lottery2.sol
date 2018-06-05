pragma solidity ^0.4.4;

/**
 * @title Lottery
 * @author Andres Monteoliva Mosteiro ---version 1.2 (Lottery with gas optimization)
 * @dev Lottery game, with a prefixed pot where users can participate via the
 * participate the purchase of tokensRaised.
 * @author Andres Monteoliva Mosteiro
 */

contract Lottery {

  uint constant public threshold = 100000000;
  uint constant public rate = 1;

  uint public weiRaised = 0;

  mapping (uint256 => address) private tokenBuyers;
  mapping  (address => uint256) private tokenBalances;

  address public winnerAddress;

  uint256 private firstBuyer = 0;
  uint256 private lastBuyer = 0;
  bool public lotteryFinished = false;


/**
 * @dev Function to buy tokens for the Lottery. It cannot be called from
 * inside the contract.
 */

  function buyTokens() external payable {

    require(msg.value > 0);
    require(msg.value + weiRaised <= threshold);
    require(!lotteryFinished);

    //Calculate number of tokens to be created
    uint256 tokens = msg.value * rate;
    //Update state of the Wei raised.
    weiRaised = weiRaised + msg.value;

    if(tokenBalances[msg.sender] == 0){
      tokenBuyers[lastBuyer] = msg.sender;
      lastBuyer++;
    }

    tokenBalances[msg.sender] += tokens;

  }

/**
 * @dev Function which runs the Lottery . It is required that the threshold
 * is been reached. Only external calls.
 */
  function runLottery() external{

    require(weiRaised == threshold);
    require(!lotteryFinished);


    uint winnerNumber =  calculateWinner();
    uint tokenIndex = 0;

    for(uint256 buyerIndex = firstBuyer; buyerIndex <= lastBuyer; buyerIndex++){
        address buyer = tokenBuyers[buyerIndex];
        tokenIndex += tokenBalances[buyer];

        if( (tokenIndex > winnerNumber) && !(lotteryFinished)){
            lotteryFinished = true;
            winnerAddress = buyer;
        }
        // clear all the token balances of all players
        tokenBalances[buyer] = 0;
    }

    uint256 prize = weiRaised;
    //Update state before interaction with external contracts.
    weiRaised = 0;
    //Send the prize to the winner
    winnerAddress.transfer(prize);

    firstBuyer = lastBuyer;
    lotteryFinished = false;
  }

/**
 * @dev Calculates the winner number, achieving the "randomness" from the hash
 * of the last block mined.
 * @return An uint which holds the winner number.
 */
  function calculateWinner() internal constant returns(uint) {

    uint256 blockNumber = block.number - 1;
    uint256 blockHash = uint(block.blockhash(blockNumber));

    //Retrieving a random number within the desired range.
    uint256 winnerNumber = (blockHash % threshold);
    return winnerNumber;
  }

}
