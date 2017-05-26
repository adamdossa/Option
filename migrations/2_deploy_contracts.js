var CallOption = artifacts.require("./CallOption.sol");
var PutOption = artifacts.require("./PutOption.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");
//price, expiry, notional, strike
module.exports = function(deployer) {
  // deployer.deploy(SimpleToken);
  deployer.deploy(SimpleToken).then(function() {
    return deployer.deploy(CallOption, 0, SimpleToken.address, 1000, 999, 500, 25);
  }).then(function() {
    return deployer.deploy(PutOption, 1, SimpleToken.address, 2000, 1999, 250, 35);
  });
};
