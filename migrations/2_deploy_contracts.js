var NppToken = artifacts.require("./NppToken.sol");
var CrowdSale = artifacts.require("./CrowdSale.sol");

module.exports = function(deployer) {
  deployer.deploy(NppToken);
  //deployer.deploy(CrowdSale); //TODO: arguments
};
