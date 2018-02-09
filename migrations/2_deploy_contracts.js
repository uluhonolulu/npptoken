    const NppToken = artifacts.require("./NppToken.sol");
    var CrowdSale = artifacts.require("./CrowdSale.sol");

    module.exports = async function(deployer) {
      deployer.deploy(NppToken).then(() => {
        console.log("NppToken.address (async): " + NppToken.address);

        return deployer.deploy(CrowdSale, NppToken.address);
      }).then(async () => {
        console.log("CrowdSale.address: " + CrowdSale.address);

        var token = await NppToken.deployed();
        var owner = await token.owner.call();
        console.log("Current token owner: " + owner);
        console.log("token.address: " + token.address);

        await token.transferOwnership(CrowdSale.address);
        owner = await token.owner.call();
        console.log("New token owner: " + owner);
        
      });
      
    };
