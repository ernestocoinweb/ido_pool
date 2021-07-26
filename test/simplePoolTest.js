var Pool = artifacts.require("./Pool.sol");
var MyToken = artifacts.require("./MyToken.sol");

contract("Pool - basic initialization", function(accounts) {
    const poolOwner = accounts[1];
    const investor1 = accounts[2];
    const investor2 = accounts[3];
    
    it("simple test", async () => {
	const projectToken = await MyToken.deployed(1000);	
    });
})
