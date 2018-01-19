var token = artifacts.require("./NppToken.sol");
var ico = artifacts.require("./CrowdSale.sol");


//Some default values for gas
var gasAmount = 3000000;
var gasPrice = 20000000000;

contract('Crowdsale', ([owner, investor]) => {
    describe('Initially', () => {
        beforeEach(async () => {
            this.tokenInstance = await token.deployed();
            this.icoInstance = await ico.new(owner, this.tokenInstance.address);
        });

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

        it('Distribute returns "NOT_CONFIRMED"', async () => {
            var result = await this.icoInstance.distribute(investor, 1, {from: owner, gasPrice:gasPrice, gas:gasAmount } );
            console.log("Distribute: " + result);
        });
    });  
    
    describe('After investor sent us 0 ETH', () => {
        beforeEach(async () => {
            this.tokenInstance = await token.deployed();
            this.icoInstance = await ico.new(owner, this.tokenInstance.address);
            const { logs } = await this.icoInstance.sendTransaction({ value: 0, from: investor });
        });

        it('her address should be cofirmed', async () => {
            var isConfirmed = await this.icoInstance.isConfirmed(investor);
            assert.isTrue(isConfirmed);            
        });
    });
});


