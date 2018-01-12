pragma solidity ^0.4.18;
import '../node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';
import '../node_modules/zeppelin-solidity/contracts/math/Math.sol';
import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol';

contract NppToken is StandardToken {
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
 * - Prepare a spreadsheet for token allocation
 * - Deploy this contract, with the sum to tokens to be distributed, from the owner account
 * - Call setInvestor for all investors from the owner account using a local script and CSV input
 * - Move tokensToBeAllocated in this contract usign StandardToken.transfer()
 * - Call lock from the owner account
 * - Wait until the freeze period is over
 * - After the freeze time is over investors can call claim() from their address to get their tokens
 *
 */
contract CrowdSale is Ownable {

  /** How many investors we have now */
  uint public investorCount;

  /** Sum from the spreadsheet how much tokens we should get on the contract. If the sum does not match at the time of the lock the vault is faulty and must be recreated.*/
  uint public tokensToBeAllocated;

  /** How many tokens investors have claimed so far */
  uint public totalClaimed;

  /** How many tokens our internal book keeping tells us to have at the time of lock() when all investor data has been loaded */
  uint public tokensAllocatedTotal;

  /** How much we have allocated to the investors invested */
  mapping(address => uint) public balances;

  /** How many tokens investors have claimed */
  mapping(address => uint) public claimed;

  /** We can also define our own token, which will override the ICO one ***/
  NppToken public token;

  /** We allocated tokens for investor */
  event Allocated(address investor, uint value);

  /** We distributed tokens to an investor */
  event Distributed(address investors, uint count);

  /**
   * Create presale contract where lock up period is given days
   *
   * @param _owner Who can load investor data and lock
   * @param _freezeEndsAt UNIX timestamp when the vault unlocks
   * @param _token Token contract address we are distributing
   * @param _tokensToBeAllocated Total number of tokens this vault will hold - including decimal multiplcation
   *
   */
  function CrowdSale(address _owner, NppToken _token, uint _tokensToBeAllocated) public {

    owner = _owner;

    require(owner != 0);

    token = _token;

    // Give argument
    require(_freezeEndsAt != 0);

    freezeEndsAt = _freezeEndsAt;
    tokensToBeAllocated = _tokensToBeAllocated;
  }

  /**
   * Add a presale participatin allocation.
   */
  function setInvestor(address investor, uint amount) public onlyOwner neverLocked {

    require(amount > 0);              // No empty buys
    require(balances[investor] == 0); // Don't allow multiple calls for a single investor


    balances[investor] = amount;

    investorCount++;

    tokensAllocatedTotal += amount;

    Allocated(investor, amount);
  }

  /**
   * Lock the vault.
   *
   *
   * - All balances have been loaded in correctly
   * - Tokens are transferred on this vault correctly
   *
   * Checks are in place to prevent creating a vault that is locked with incorrect token balances.
   *
   */
  function lock() public onlyOwner neverLocked {

    // Do not lock the vault if we allocated more than we have tokens
    // Note that we do not check != so that we can top up little bit extra
    // due to decimal rounding and having issues with it.
    // This extras will be lost forever when the vault is locked.
    require(token.balanceOf(address(this)) >= tokensAllocatedTotal);

    lockedAt = now;

    Locked();
  }

  /**
   * In the case locking failed, then allow the owner to reclaim the tokens on the contract.
   */
  function recoverFailedLock() public onlyOwner neverLocked {

    // Transfer all tokens on this contract back to the owner
    token.transfer(owner, token.balanceOf(address(this)));
  }

  /**
   * Get the current balance of tokens in the vault.
   */
  function getBalance() public constant returns (uint howManyTokensCurrentlyInVault) {
    return token.balanceOf(address(this));
  }

  /**
   * Claim N bought tokens to the investor as the msg sender.
   *
   */
  function claim() public {

    address investor = msg.sender;

    State currentState = getState();
    require(currentState == State.Distributing);  //lock period ended
    require(balances[investor] > 0);              //we know this investor
    require(claimed[investor] == 0);              //haven't claimed yet

    uint amount = balances[investor];

    claimed[investor] = amount;

    totalClaimed += amount;

    token.transfer(investor, amount);

    Distributed(investor, amount);
  }


  //TODO: fallback function
}