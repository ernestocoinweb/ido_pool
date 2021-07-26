var Pool = artifacts.require("./Pool.sol");
var MyCoin = artifacts.require("./MyToken.sol");

module.exports = function(deployer) {
    deployer.deploy(MyCoin, 1000).then(function() {  
	return deployer.deploy(Pool, MyCoin.address, MyCoin.address);
    });
};
