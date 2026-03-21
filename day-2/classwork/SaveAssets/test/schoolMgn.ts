import { ethers } from "hardhat";
import {expect} from "chai";

describe("schoolMgn", function () {
    let erc20Token: any,
        schoolMgn: any,
        erc20TokenAddress: any,
        principal: any, 
        addr2: any,
        addr3: any;
    
    beforeEach(async function () {
        const ERC20Token = await ethers.getContractFactory("ERC20");
        const SchoolMgn = await ethers.getContractFactory("SchoolMgn");
        [principal, addr2, addr3] = await ethers.getSigners();

        erc20Token = await ERC20Token.deploy("SchoolToken", "ST", 18n);
        await erc20Token.waitForDeployment();;

        erc20TokenAddress = await erc20Token.getAddress();

        schoolMgn = await SchoolMgn.deploy(erc20TokenAddress);
        await schoolMgn.waitForDeployment();

        
    });

    it("should correctly return the name, symbol and decimal for the erc20 token", async function () {
    expect(await erc20Token.name()).to.equal("SchoolToken");
    expect(await erc20Token.symbol()).to.equal("ST");
    expect(await erc20Token.decimals()).to.equal(18n);
    });

    it("should set the token address corectly", async function () {
        expect(await schoolMgn.token()).to.be.eq(erc20TokenAddress);
    });

    it("should set the principal deployer", async function () {
        expect(await schoolMgn.principal()).to.equal(principal.address);
    });

    it("should set levelFees correctly", async function (){
        expect(await schoolMgn.levelFees(100)).to.be.eq(ethers.parseEther("1000"));
        expect(await schoolMgn.levelFees(200)).to.be.eq(ethers.parseEther("2000"));
        expect(await schoolMgn.levelFees(300)).to.be.eq(ethers.parseEther("3000"));
        expect(await schoolMgn.levelFees(400)).to.be.eq(ethers.parseEther("4000"));
    })

    it("should set levelSalary correctly", async function (){
        expect(await schoolMgn.levelSalary(100)).to.be.eq(ethers.parseEther("100"));
        expect(await schoolMgn.levelSalary(200)).to.be.eq(ethers.parseEther("200"));
        expect(await schoolMgn.levelSalary(300)).to.be.eq(ethers.parseEther("300"));
        expect(await schoolMgn.levelSalary(400)).to.be.eq(ethers.parseEther("400"));
    })

    it("should allow principal to register students", async function (){
        const schoolFee = ethers.parseUnits("1200", 18);

        await erc20Token.mint(principal.address, schoolFee);

        await erc20Token.connect(principal).approve(schoolMgn.target, schoolFee);
        
        await expect(schoolMgn.connect(principal).registerStudent("Femi", 100)).to.not.be.reverted;
    });
    
} )