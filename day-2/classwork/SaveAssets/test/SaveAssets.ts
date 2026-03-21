import { ethers } from "hardhat";
import { expect } from "chai";
// import { clear, error } from "console";

describe("SaveAssets", function () {
  let erc20Token: any, saveAsset: any, addr1: any, addr2: any, addr3: any;

  beforeEach(async function () {
    const ERC20Token = await ethers.getContractFactory("ERC20");
    const SaveAsset = await ethers.getContractFactory("SaveAssets");
    [addr1, addr2, addr3] = await ethers.getSigners();

    erc20Token = await ERC20Token.deploy("MyToken", "MTK", 18n);
    await erc20Token.waitForDeployment();

    const erc20TokenAddress = await· erc20Token.getAddress();

    saveAsset = await SaveAsset.deploy(erc20TokenAddress);
    await saveAsset.waitForDeployment();

    const saveAssetAddress = await saveAsset.getAddress();
    });

    it("should correctly return the name, symbol and decimal for the erc20 token", async function () {
    expect(await erc20Token.name()).to.equal("MyToken");
    expect(await erc20Token.symbol()).to.equal("MTK");
    expect(await erc20Token.decimals()).to.equal(18n);
    
    });

    it("should be able to deposit ether in save asset contract", async function () {
    const depositAmount = ethers.parseEther("2");
    await saveAsset.connect(addr1).depositEther({ value : depositAmount });
    expect(await saveAsset.connect(addr1).getUserSavings()).to.eq(depositAmount);
    });

    it("should not be able to deposit 0 ether in save asset contract", async function () {
    await expect(
      saveAsset.connect(addr2).depositEther({ value: 0 }),
    ).to.be.revertedWith("Amount must be greater than zero");
    });

   it("should be able to withdraw ether", async function () {
    const depositAmount = ethers.parseEther("2");
    await saveAsset.connect(addr1).depositEther({ value : depositAmount });
    const withdrawAmount = ethers.parseEther("1");
    const addr1OldBalance = await ethers.provider.getBalance(addr1);
     
    await saveAsset.connect(addr1).withdrawEther(withdrawAmount);
    const addr1NewBalance = await ethers.provider.getBalance(addr1);
    expect(addr1NewBalance - addr1OldBalance).to.be.closeTo(withdrawAmount, ethers.parseUnits("1000000000000"));
   });

   it("should not be able to withdraw 0 ether from the contract", async function () {
    await expect(saveAsset.connect(addr1).withdrawEther(0),).to.be.reverted;
   });

   it("should not be able to withdraw amount higher than balance", async function () {
    const depositAmount = ethers.parseEther("1");
    await saveAsset.connect(addr1).depositEther({value: depositAmount});

    const withdrawAmount = ethers.parseEther("12000");

    await expect( saveAsset.connect(addr1).withdrawEther(withdrawAmount)).to.be.reverted; 
   })
   
   it("should be able to deposit erc20Token in SaveAssets", async function () {
    const depositAmount = ethers.parseUnits("5", 18 );

    await erc20Token.mint(addr1.address, depositAmount);

    await erc20Token.connect(addr1).approve(saveAsset.target, depositAmount);

    await saveAsset.connect(addr1).depositErc20(depositAmount);

    expect(await saveAsset.connect(addr1).getErc20SavingsBalance()).to.be.eq(depositAmount); 
   });
   
   it("should not be able to deposit zero amount", async function () {
    await expect(saveAsset.connect(addr1).depositErc20(0)).to.be.reverted;
   })

   it("it should be able to withdraw erc20token to an address", async function () {
    const depositAmount = ethers.parseUnits("5", 18 );

    await erc20Token.mint(addr1.address, depositAmount);

    await erc20Token.connect(addr1).approve(saveAsset.target, depositAmount);

    await saveAsset.connect(addr1).depositErc20(depositAmount);

    const oldBalance = await ethers.provider.getBalance(addr1);

    const withdrawAmount = ethers.parseUnits("4", 18 );

    await saveAsset.connect(addr1).withdrawErc20(withdrawAmount);

    const newBalance = await ethers.provider.getBalance(addr1);

    expect (newBalance - oldBalance).to.be.closeTo(withdrawAmount, ethers.parseUnits("1000000000000"));

  });

  it("should not be able to withdraw zero amount", async function () {
    await expect(saveAsset.connect(addr1).withdrawErc20(0)).to.be.reverted;
  });

  it("should not be able to withdraw amount higher than balance", async function () {
    const depositAmount = ethers.parseUnits("5", 18 );

    await erc20Token.mint(addr1.address, depositAmount);

    await erc20Token.connect(addr1).approve(saveAsset.target, depositAmount);

    await saveAsset.connect(addr1).depositErc20(depositAmount);

    const withdrawAmount = ethers.parseUnits("6", 18 );

    await expect(saveAsset.connect(addr1).withdrawErc20(withdrawAmount)).to.be.reverted;
  });
});
