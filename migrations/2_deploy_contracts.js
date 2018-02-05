    var NppToken = artifacts.require("./NppToken.sol");
    var CrowdSale = artifacts.require("./CrowdSale.sol");

    module.exports = async function(deployer) {
      await Promise.all([
        deployer.deploy(NppToken),
        deployer.deploy(CrowdSale, NppToken.address)
      ]);
      console.log("CrowdSale.address: " + CrowdSale.address);
      
      var token = await NppToken.deployed();
      var owner = await token.owner.call();
      console.log("Current token owner: " + owner);

      await token.transferOwnership(CrowdSale.address);
      owner = await token.owner.call();
      console.log("New token owner: " + owner);
    };
