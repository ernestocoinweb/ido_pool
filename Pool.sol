// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

import "./6_MyToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

enum PoolStatus { Cancelled , Paused, Finished, Upcoming, Ongoing }

contract Pool {

    struct Investor {
        uint projectTokenAmount; 
        address wallet; 
        bool isWhitelisted;
     }
    
    struct PoolData {
        Investor [] investors;
        uint projectSoldTokens;
        uint tokenPrice;
        uint exchangeRate;
        
        address mainTokenAddress;
        
        uint softCap;
        uint hardCap;
        
        uint projectTotalTokens;
        uint maxAllocationPerUser;
        uint minAllocationPerUser;
        
        uint startDateTime;
        uint endDateTime;
        
        PoolStatus status;
    }
    
    uint startDateTime;
    uint endDateTime;
    
    address poolOwner;

    address walletAddress;       // where investors tokens go
   
    address mainCoinAddress;      // = 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95; // address of investors tokens
    ERC20 public mainCoinToken;

    address projectTokenAddress;  // = 0xa131AD247055FD2e2aA8b156A11bdEc81b9eAD95; // address of offered tokens
    ERC20 public projectToken;
    uint projectAvailableTokens;
    uint projectTotalTokens;
    
    uint projectTokenPerMainToken; // exchange rate
    
    // mapping (address => Investor) investors;  can not be a map as we need to return them in getPoolData
    Investor [] investors;
    Investor dummyInvestor; // refrence used for getInvestor if it is not found
    
    uint    minAllocationPerUser;
    uint    maxAllocationPerUser;
    
    uint    hardCap; // how much to raise
    uint    softCap; // how much it will be accepted as a successful IDO
    uint    collectedMainTokens;  // how much is being raised
    
    PoolStatus status;


    // Should add more parameters and not hardcode them in the code, but for easy testing
    constructor (address _mainCoinAddress, address _walletAddress) {    
        poolOwner       = msg.sender;
         
        mainCoinToken   = MyToken(_mainCoinAddress);   // This is an existing crypto currency or token for investors, should not be created here as projectToken
        walletAddress   = _walletAddress;              // where investors main tokens go
        
        projectToken           = new MyToken(100); // project offers ERC-20 compliance tokens 
        projectTokenAddress    = address(projectTokenAddress);
        projectAvailableTokens = 100;
        projectTotalTokens     = 100;
         
        startDateTime   = block.timestamp;
        endDateTime     = block.timestamp + 1000000; //_poolTime;
        
        minAllocationPerUser = 4; 
        maxAllocationPerUser = 6; 
        
        softCap = 20;
        hardCap = 25;
        
        projectTokenPerMainToken = 3;
    }

    /** 
     * @dev Get the pool data.
     */
    function getPoolData() public returns (PoolData memory poolData) {
      
        return PoolData({
            investors: investors,
            projectSoldTokens: projectTotalTokens - projectAvailableTokens,
            tokenPrice: 1*(10**2)/projectTokenPerMainToken, // returns main token in cents
            exchangeRate: projectTokenPerMainToken,
            mainTokenAddress: mainCoinAddress,
            softCap: softCap,
            hardCap: hardCap,
            projectTotalTokens: projectTotalTokens,
            maxAllocationPerUser: maxAllocationPerUser,
            minAllocationPerUser: minAllocationPerUser,
            status: getState(),
            startDateTime: startDateTime,
            endDateTime: endDateTime
        });
    }
    
    function addInvestor(address [] memory investorsToWhitelist) public {
        require(
            msg.sender == poolOwner,
            "Only the pool owner whitelist wallets."
        );
        
        for (uint i=0; i < investorsToWhitelist.length; i++) {
            investors.push(Investor({
                wallet: investorsToWhitelist[i],
                projectTokenAmount: 0,
                isWhitelisted: true
            }));
        }
        
    }
    
    function getInvestor(address investor) private returns (Investor storage investorRef) {
          for (uint i=0; i < investors.length; i++) {
            if (investors[i].wallet == investor)
                return investors[i];
        }
        
        dummyInvestor.wallet = investor;
        dummyInvestor.isWhitelisted = false;
        dummyInvestor.projectTokenAmount = 0;
        
        return dummyInvestor;
    }
    
    function getState() public returns (PoolStatus updatedStatus) {
        if (startDateTime <= block.timestamp && block.timestamp <= endDateTime 
            && status != PoolStatus.Cancelled && status != PoolStatus.Paused && status != PoolStatus.Ongoing)
            status = PoolStatus.Ongoing;
        else if (block.timestamp > endDateTime 
                 && status != PoolStatus.Cancelled && status != PoolStatus.Paused && status != PoolStatus.Finished) 
            status = PoolStatus.Finished;
        else if (block.timestamp < startDateTime 
                 && status != PoolStatus.Cancelled && status != PoolStatus.Paused && status != PoolStatus.Upcoming)
            status = PoolStatus.Upcoming;
        
        return status;
    }
    
    function invest(uint mainTokenAmount) public {
        Investor storage investor = getInvestor(msg.sender);    
        require(investor.isWhitelisted, "Not whitelisted address");
        
        require(getState() == PoolStatus.Ongoing, "Pool is not ongoing");
        
        uint projectTokenAmount = mainTokenAmount * projectTokenPerMainToken;
        
    
        
        require(projectTokenAmount + investor.projectTokenAmount >= minAllocationPerUser, "Minimun allocation not satisfied");
        require(projectTokenAmount + investor.projectTokenAmount <= maxAllocationPerUser, "Maximum allocation exceeded");
        require(mainTokenAmount + collectedMainTokens <= hardCap, "HardCap is exceeded");
        
        // the investor have approved the mainTokenAmount amount by calling the approve function beforehand for mainCoinToken
        uint allowed = ERC20(mainCoinToken).allowance(msg.sender, walletAddress);
        require(allowed >= mainTokenAmount, "Check the invested token allowance");
        
        require(projectTokenAmount <= projectAvailableTokens, "Not enough available tokens");

        ERC20(mainCoinToken).transferFrom(msg.sender, walletAddress, mainTokenAmount);

        projectAvailableTokens -= projectTokenAmount;
        investor.projectTokenAmount += projectTokenAmount;
        collectedMainTokens += mainTokenAmount;
    }
    
    function retriveInverstor(address walletTo) public {
        require(getState() == PoolStatus.Finished, "Pool is not finished");
        
        Investor storage investor = getInvestor(msg.sender);      
        
        require(investor.projectTokenAmount > 0, "Investor did not invest in this Pool");
        
        ERC20(projectToken).transfer(walletTo, investor.projectTokenAmount);
    }
    
    function retriveProject() public {
        require(getState() == PoolStatus.Finished, "Pool is not finished");
        require(collectedMainTokens > 0, "No main tokens");
        
        uint total = ERC20(mainCoinToken).balanceOf(walletAddress);
        ERC20(mainCoinToken).transferFrom(walletAddress, poolOwner, total);
        collectedMainTokens = 0;
    }
}