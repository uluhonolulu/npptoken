pragma solidity ^0.4.19;
import '../node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';
import '../node_modules/zeppelin-solidity/contracts/math/Math.sol';
import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol';

contract NppToken is StandardToken, Ownable {
  string public constant name = "Nanopowder Token";
  string public constant symbol = "NPP";
  uint8 public constant decimals = 0; 
  uint256 public constant INITIAL_SUPPLY = 20000000 * (10 ** uint256(decimals));  //20M tokens
  address public contractAddress; //this contract's address

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function PplToken() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    contractAddress = this;
  }

  //override transfer to ensure we don't receive any tokens
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != contractAddress);
    return super.transfer(_to, _value);
  }

  /**
   * burn investor's tokens
   */
  function burn(address _owner, uint256 _value) public onlyOwner {
    require(_value > 0);
    balances[_owner] = balances[_owner].sub(_value);
  }

  //override the fallback function to ensure we don't accept ether
  function() public payable {
      revert();
  }
}


/**
 * Hold tokens for a group investor of investors until the unlock date.
 *
 * After the unlock date the investor can claim their tokens.
 *
 * Steps
 *
 * - Prepare a list of investors/amounts for token allocation
 * - Deploy this contract, with the sum to tokens to be distributed, from the owner account
 * - Move tokensToBeAllocated in this contract usign StandardToken.transfer()
 * - Investor confirms her address by sending 0.0ETH to this address
 * - Call distribute for investor to give her the tokens
 *
 */
contract CrowdSale is Ownable {

  /** How many tokens have been distributed */
  uint public tokensAllocatedTotal;

  address[] private confirmedAddresses;

  address[] private handledAddresses;  // the ones we distributed the tokens to

  NppToken private token;

  /**
   * Create crowdsale contract where lock up period is given days
   *
   * @param _owner Who can load investor data
   * @param _token Token contract address we are distributing
    *
   */
  function CrowdSale(address _owner, NppToken _token) public {
    require(owner != 0);
    owner = _owner;
    token = _token;
  }

  /**
   * Send tokens to the investor
   * @param _investor The investor's address for tokens
   * @param _amount How many tokens we should send
   */
  function distribute(address _investor, uint256 _amount) public onlyOwner returns (string) {
    require(_amount > 0);              // No empty buys

    //verify that the address is confirmed
    if (!isConfirmed(_investor)) {
      return "NOT_CONFIRMED";
    }
    //verify that we haven't trasferred for this investor yet
    if (isHandled(_investor)) {
      return "DUPLICATE";
    }    
    //transfer the tokens
    if(token.transfer(_investor, _amount)){
      tokensAllocatedTotal += _amount;
      handledAddresses.push(_investor);      
      return "OK";
    } else {
      return "TRANSFER_FAILED"; //perhaps not enough tokens left?
    }
  }

  /**
   * Burn the investor's tokens
   * @param _investor The Investor's address 
   * @param _amount How many tokens to burn
   */
  function burn(address _investor, uint256 _amount) public onlyOwner {
    token.burn(_investor, _amount);
  }

  /**
   * Get the current balance of tokens in the vault.
   */
  function getBalance() public constant returns (uint howManyTokensCurrentlyInVault) {
    return token.balanceOf(address(this));
  }

  /**
   * The fallback function is used for confirming the user's address
   */
  function() public payable {
    confirmedAddresses.push(msg.sender);
  }

  function isConfirmed(address _address) public constant returns (bool) {
    for (uint index = 0; index < confirmedAddresses.length; index++) {
      if (confirmedAddresses[index] == _address) {
        return true;
      } 
    }
    return false;
  }

  function isHandled(address _address) private constant returns (bool) {
    for (uint index = 0; index < handledAddresses.length; index++) {
      if (handledAddresses[index] == _address) {
        return true;
      } 
    }
    return false;
  }
}