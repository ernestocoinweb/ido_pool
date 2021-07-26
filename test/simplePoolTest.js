var Pool = artifacts.require("./Pool.sol");
var MyToken = artifacts.require("./MyToken.sol");

contract("Pool - basic initialization", function(accounts) {
    const poolOwner = accounts[1];
    const investor1 = accounts[2];
    const investor2 = accounts[3];
    const investor3 = accounts[4];  // not whitelisted

    
    it("simple test", async () => {
	const projectToken = await MyToken.deployed(1000);
	const pool         = await Pool.deployed(projectToken.address, poolOwner.address, {from: poolOwner});		

	//await pool.addInvestors([investor1, investor2], {from:poolOwner});
	await pool.getPoolData();
    });
})
