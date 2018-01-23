var NppToken = artifacts.require("./NppToken.sol");
var CrowdSale = artifacts.require("./CrowdSale.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(NppToken);
  deployer.deploy(CrowdSale, NppToken.address);
  //TODO: set owner
};
