var token = artifacts.require("./NppToken.sol");
var ico = artifacts.require("./CrowdSale.sol");


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

        xit('balance should be equal to initial balance', async () => {
            var balance = await this.tokenInstance.balanceOf(this.icoInstance.address); //this.icoInstance.getBalance.call();
            var INITIAL_SUPPLY = await this.tokenInstance.INITIAL_SUPPLY.call();
            console.log(this.icoInstance.address);
            var tokenOwner = await this.tokenInstance.owner()
            console.log(tokenOwner);
            assert.equal(balance.toString(), INITIAL_SUPPLY.toString());
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


