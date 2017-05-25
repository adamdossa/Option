var CallOption = artifacts.require("./CallOption.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleToken).then(function() {
    return deployer.deploy(CallOption, SimpleToken.address, 1000, 999, 500, 25);
  });
};
