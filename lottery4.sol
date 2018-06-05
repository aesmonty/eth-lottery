pragma solidity ^0.4.4;

/**
 * @title Lottery
 * @author Andres Monteoliva Mosteiro --version 1.4 Owner optimization
 * @dev Lottery game, with a prefixed pot where users can participate via the
 * participate the purchase of tokensRaised.
 * @author Andres Monteoliva Mosteiro
 */

contract Lottery {

  uint constant public threshold = 100000000;
  uint constant public rate = 1;

  uint private weiRaised = 0;
  uint private tokensRaised = 0;

  address public owner = msg.sender;


  mapping (uint256 => address) private tokenBuyers;
  mapping  (address => uint256) private tokenBalances;
  mapping  (address => uint256) private weiRefunds;

  address public winnerAddress;

  uint256 private firstBuyer = 0;
  uint256 private lastBuyer = 0;
  bool public lotteryFinished = false;


/**
*@dev Modifier which  restricts a feature of the contract for all the users
*excepting the owner (creator) of the contract.
*/
  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }


/**
 * @dev Function to buy tokens for the Lottery. It cannot be called from
 * inside the contract.
 */

  function buyTokens() external payable {

    require(msg.value > 0);
    require(weiRaised < threshold);
    require(!lotteryFinished);

    uint256 weiAmount = msg.value;
    //Check if the threshold is surpassed wih the token sale.
    if(weiAmount + weiRaised > threshold){
      //Calculate the surpassed difference on of the threshold,which will be refunded.
      uint refund = weiAmount + weiRaised - threshold;
      weiRefunds[msg.sender] += refund;
      //Update the amount of wei which is going to be exchanged for tokens.
      weiAmount = weiAmount - refund;
    }

    //Calculate number of tokens to be created
    uint256 tokens = weiAmount * rate;
    //Update state of the Wei raised.
    weiRaised = weiRaised + weiAmount;

    if(tokenBalances[msg.sender] == 0){
      tokenBuyers[lastBuyer] = msg.sender;
      lastBuyer++;
    }

    tokenBalances[msg.sender] += tokens;
    tokensRaised = tokens + tokensRaised;

  }

/**
 * @dev Function which runs the Lottery . It is required that the threshold
 * is been reached. Only external calls.
 */
  function runLottery() external onlyOwner(){

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


    //Update the prize for the winner
    weiRefunds[winnerAddress] += (9*weiRaised)/10;
    weiRefunds[owner]+= weiRaised/10;
    //Clear state. New lottery ready.
    weiRaised = 0;
    tokensRaised = 0;
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

  /**
 * @dev Function to claim refunds and prices. Untrusted- interaction with
 * untrusted contracts. Pull over push for external calls.
 */
  function untrusted_withdrawRefund() external {
       uint256 refund = weiRefunds[msg.sender];
       weiRefunds[msg.sender] = 0;
       msg.sender.transfer(refund);
   }
}
