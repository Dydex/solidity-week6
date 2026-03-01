const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const TETHERAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const DAI = await ethers.getContractAt(
    "IERC20",
    DAIAddress,
    impersonatedSigner
    );

    const UniRouterContract = await ethers.getContractAt(
    "IUniswapV2Router",
    UNIRouter,
    impersonatedSigner
    );

    const TETHER = await ethers.getContractAt(
        "IERC20",
        TETHERAddress,
        impersonatedSigner
    );

    const amountIn = ethers.parseUnits("5000", 18);

    const amountOutMin = ethers.parseUnits("3000", 6);

    const path = [DAIAddress, TETHERAddress];

    const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

    const daiBalanceBefore = await DAI.balanceOf(impersonatedSigner);

    const tetherBalanceBefore = await TETHER.balanceOf(impersonatedSigner);

    await DAI.approve(UNIRouter, amountIn);

    console.log("=======Before============");

    console.log("dai balance before", ethers.formatUnits(daiBalanceBefore, 18));
    console.log("tether balance before", ethers.formatUnits(tetherBalanceBefore, 6));

    const transaction = await UniRouterContract.swapExactTokensForTokens(
        amountIn,
        amountOutMin,
        path,
        impersonatedSigner,
        deadline,      
    );

    await transaction.wait();

    console.log("=======After============");
    const daiBalanceAfter = await DAI.balanceOf(impersonatedSigner);
    const tetherBalanceAfter = await TETHER.balanceOf(impersonatedSigner);
    console.log("dai balance after", ethers.formatUnits (daiBalanceAfter, 18));
    console.log("tether balance after", ethers.formatUnits(tetherBalanceAfter, 6));

    console.log("=========Difference==========");
    const newDaiValue = daiBalanceBefore - daiBalanceAfter;
    const tetherMustValue = tetherBalanceAfter - tetherBalanceBefore;
    console.log("DAI USED: ", ethers.formatUnits(newDaiValue, 18));
    console.log("TETHER USED: ", ethers.formatUnits(tetherMustValue, 6));

};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});