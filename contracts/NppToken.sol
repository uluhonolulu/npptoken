pragma solidity ^0.4.18;
import '../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
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
   * @dev Constructor that gives msg.sender all tokens.
   */
  function NppToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    contractAddress = this;
  }

  
  /**
   * @dev override transfer to ensure we don't receive any tokens
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != contractAddress);
    return super.transfer(_to, _value);
  }

  /**
   * @dev burn investor's tokens
   */
  function burn(address _owner, uint256 _value) public onlyOwner {
    require(_value > 0);
    balances[_owner] = balances[_owner].sub(_value);
  }

  /**
   * @dev If we upgrade the CrowdSale contract, transfer owner and all remaining tokens to the new version
   */
  function setOwnerAndTransferTokens(address _newOwner) public onlyOwner {
    transferOwnership(_newOwner);
    transfer(_newOwner, balances[msg.sender]);
  }

  /**
   * @dev override the fallback function to ensure we don't accept ether
   */
  function() public payable {
      revert();
  }
}


/**
 * The contract that manages ICO
 *
 * Steps
 *
 * - Prepare a list of investors/amounts for token allocation
 * - Deploy this contract from the owner account; the initial token supply will belong to this contract
 * - Investor confirms her address by sending 0.0ETH to this address
 * - Call checkStatus(address) to make sure we can send the tokens to this investor (to make sure the address is confirmed)
 * - Call distribute() for investor to give her the tokens
 * - Call burn() to burn one's tokens (to change them for shares)
 *
 */
contract CrowdSale is Ownable {

  /** How many tokens have been distributed */
  uint public tokensAllocatedTotal;

  mapping (address => bool) private confirmedAddresses; //list of confirmed addresses

  mapping (address => bool) private handledAddresses;   //list of addresses that have got the tokens

  NppToken private token;


  /**
   * Create crowdsale contract 
   *
   * @param _tokenAddress Token contract address we are distributing
    *
   */
  function CrowdSale(address _tokenAddress) Ownable() public {
    require(_tokenAddress != address(0));
    token = NppToken(_tokenAddress);
  }

  /**
   * Check the investor's status. IMPORTANT: Always do this before calling "distribute". 
   */
  function checkStatus(address _investor) public view onlyOwner returns (string) {
    //verify that the address is confirmed
    if (!isConfirmed(_investor)) {
      return "NOT_CONFIRMED";
    }

    //verify that we haven't trasferred for this investor yet
    if (isHandled(_investor)) {
      return "DISTRIBUTED";
    }

    //all checks passed
    return "OK";
  }
  

  /**
   * Send tokens to the investor
   * @param _investor The investor's address for tokens
   * @param _amount How many tokens we should send
   */
  function distribute(address _investor, uint256 _amount, bool _force) public onlyOwner returns (string) {
    require(_amount > 0);              // No empty buys

    //verify the address is confirmed
    require(isConfirmed(_investor) || _force);

    //verify that we haven't trasferred for this investor yet
    require(!isHandled(_investor) || _force);
    
    //transfer the tokens
    assert (token.transfer(_investor, _amount));

    handledAddresses[_investor] = true;
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
    if (!isConfirmed(msg.sender)) {   //to make sure it's unique
      confirmedAddresses[msg.sender] = true;
    }
  }

  function isConfirmed(address _address) public constant returns (bool) {
    return confirmedAddresses[_address];
  }

  function isHandled(address _address) public constant returns (bool) {
    return handledAddresses[_address];
  }
}