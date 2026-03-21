const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const USDC = await ethers.getContractAt(
        "IERC20",
        USDCAddress,
        impersonatedSigner
    );

    const UniRouterContract = await ethers.getContractAt(
        "IUniswapV2Router",
        UNIRouter,
        impersonatedSigner
    );

    const amountOut = ethers.parseUnits("1");
    const amountInMax = ethers.parseUnits("5000", 6);
    const path = [USDCAddress,WETHAddress];
    const deadline = Math.floor(Date.now() / 1000) + 60 * 10;    

    const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner);
    const wethBalanceBefore = await ethers.provider.getBalance(impersonatedSigner);

     await USDC.approve(UNIRouter, amountInMax);

    console.log("=======Before============");
    console.log("weth balance before", ethers.formatUnits(wethBalanceBefore, 18));
    console.log("usdc balance before", ethers.formatUnits(usdcBalanceBefore, 6));

    const transaction = await UniRouterContract.swapTokensForExactETH(
        amountOut,
        amountInMax,
        path,
        impersonatedSigner,
        deadline,
    );

    await transaction.wait();

    console.log("=======After============");
    const usdcBalanceAfter = await USDC.balanceOf(impersonatedSigner);
    const wethBalanceAfter = await ethers.provider.getBalance(impersonatedSigner);
    console.log("weth balance after", ethers.formatUnits(wethBalanceAfter, 18));
    console.log("usdc balance after", ethers.formatUnits(usdcBalanceAfter, 6));

    console.log("=========Difference==========");
    console.log("weth balance difference", ethers.formatUnits(wethBalanceAfter - wethBalanceBefore, 18));
    console.log("usdc balance difference", ethers.formatUnits(usdcBalanceBefore - usdcBalanceAfter, 6));
};

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});