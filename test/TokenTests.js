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
            console.log(owner);
            var ownerBalance = await this.tokenInstance.balanceOf(owner);
            let totalSupply = await this.tokenInstance.totalSupply();
            assert.equal(totalSupply.toNumber(), ownerBalance.toNumber());
        });

        it('Investor\'s address is not confirmed', async () => {
            var isConfirmed = await this.icoInstance.isConfirmed(investor);
            assert.isFalse(isConfirmed);
        });

        it('Distribute returns "NOT_CONFIRMED"', async () => {
            //TODO: check status; and throw
            var result = await this.icoInstance.distribute(investor, 1, {from: owner, gasPrice:gasPrice, gas:gasAmount } );
        });
    });  
    
    describe('After investor sent us 0 ETH', () => {
        beforeEach(async () => {
            // this.tokenInstance = await token.deployed();
            // this.icoInstance = await ico.deployed();
            const result = await this.icoInstance.sendTransaction({ value: 33, from: investor, gas: 300000 });
            //this.icoInstance.value(1).call()();
            //var confirmed = await this.icoInstance.confirmedAddresses.call(0);
            console.log(result);

            //await this.icoInstance.call.value(44)();
        });

        it('her address should be cofirmed', async () => {
            var success  = await this.icoInstance.success.call();
            console.log("success: " + success.toString(10));
            var isConfirmed = await this.icoInstance.isConfirmed(investor);
            assert.isTrue(isConfirmed);            
        });
    });
});


