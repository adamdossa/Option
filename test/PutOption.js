var PutOption = artifacts.require("./PutOption.sol");
var SimpleToken = artifacts.require("./SimpleToken.sol");

contract('PutOption', function(accounts) {
  it("should create, collateralize then close an option", function() {
    var simpleToken;
    var putOption;
    return SimpleToken.deployed().then(function(instance) {
      simpleToken = instance;
      return PutOption.new(1, simpleToken, 2000, 1999, 250, 35);
    }).then(function(instance) {
      putOption = instance;
      assert.equal(putOption.state, 0, "contract should be pending");
      return putOption.collateralizeOption({value: 250 * 35})
      // assert.equal(instance.balance, 10000, "10000 wasn't in the first account");
    }).then(function() {
      assert.equal(putOption.state, 1, "contract should be active")
      return putOption.closeOption();
    }).then(function() {
      assert.equal(putOption.state, 4, "contract should be active")
    })
  });
});
