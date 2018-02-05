var token = artifacts.require("./NppToken.sol");
var ico = artifacts.require("./CrowdSale.sol");
//var expectThrow = require('../node_modules/zeppelin-solidity/test/helpers/expectThrow');


//Some default values for gas
var gasAmount = 3000000;
var gasPrice = 20000000000;

contract('Crowdsale', ([owner, investor]) => {
    beforeEach(async () => {
        this.tokenInstance = await token.deployed();
        this.icoInstance = await ico.deployed(); //await ico.new(this.tokenInstance.address, {from: owner});
    });

    describe('Initially', () => {
        it('Name should be "Nanopowder Token"', async () => {
            var name = await this.tokenInstance.name.call();
            assert.equal(name, "Nanopowder Token");
        });

        it('Owner should own all tokens', async () => {
            var owner = await this.tokenInstance.owner.call();
            var ownerBalance = await this.tokenInstance.balanceOf(owner);
            let totalSupply = await this.tokenInstance.totalSupply();
            assert.equal(totalSupply.toNumber(), ownerBalance.toNumber());
        });

        it('Investor\'s address is not confirmed', async () => {
            var isConfirmed = await this.icoInstance.isConfirmed(investor);
            assert.isFalse(isConfirmed);
        });

        it('CheckStatus returns "NOT_CONFIRMED"', async () => {
            var status = await this.icoInstance.checkStatus(investor);
            assert.equal(status, "NOT_CONFIRMED");
        });

        it('balance should be equal to initial balance', async () => {
            var balance = await this.tokenInstance.balanceOf(this.icoInstance.address); //this.icoInstance.getBalance.call();
            var INITIAL_SUPPLY = await this.tokenInstance.INITIAL_SUPPLY.call();
            console.log("icoInstance.address: " + this.icoInstance.address);
            var tokenOwner = await this.tokenInstance.owner()
            console.log("tokenOwner: " + tokenOwner);
            assert.equal(tokenOwner, this.icoInstance.address);
            //assert.equal(balance.toString(), INITIAL_SUPPLY.toString());
        });

        it('calling "distribute" should throw', async () => {
            await expectThrow(this.icoInstance.distribute(investor, 1, false));
        });
    });  
    
    describe('After investor sent us 0 ETH', () => {
        beforeEach(async () => {
            const result = await this.icoInstance.sendTransaction({ value: 0, from: investor });
            //console.log(result);
        });

        it('her address should be cofirmed', async () => {
            var isConfirmed = await this.icoInstance.isConfirmed(investor);
            assert.isTrue(isConfirmed);            
        });

        it('status should be "OK"', async () => {
            var status = await this.icoInstance.checkStatus(investor);
            assert.equal(status, "OK");            
        });
    });
});


//assertThrow, taken from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/test/helpers/expectThrow.js
async function expectThrow (promise) {
    try {
      await promise;
    } catch (error) {
      // TODO: Check jump destination to destinguish between a throw
      //       and an actual invalid jump.
      const invalidOpcode = error.message.search('invalid opcode') >= 0;
      // TODO: When we contract A calls contract B, and B throws, instead
      //       of an 'invalid jump', we get an 'out of gas' error. How do
      //       we distinguish this from an actual out of gas event? (The
      //       testrpc log actually show an 'invalid jump' event.)
      const outOfGas = error.message.search('out of gas') >= 0;
      const revert = error.message.search('revert') >= 0;
      assert(
        invalidOpcode || outOfGas || revert,
        'Expected throw, got \'' + error + '\' instead',
      );
      return;
    }
    assert.fail('Expected throw not received');
  };