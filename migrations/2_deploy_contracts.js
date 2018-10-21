var ecOpsLib = artifacts.require("./ECops.sol");


module.exports = function(deployer) {
  deployer.deploy(ecOpsLib);
};
