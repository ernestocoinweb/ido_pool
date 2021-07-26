var Pool = artifacts.require("./Pool.sol");
var MyToken = artifacts.require("./MyToken.sol");

module.exports = function(deployer) {
    deployer.deploy(MyToken, 1000).then(function() {  
	return deployer.deploy(Pool, MyToken.address, MyToken.address);
    });
};
