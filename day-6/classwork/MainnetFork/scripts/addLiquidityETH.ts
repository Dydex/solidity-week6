const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
    const TETHERAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const amountTETHER = ethers.parseUnits("10000", 6);
    const amountTETHERMin = ethers.parseUnits("9000", 6);
    const amountETHMin = ethers.parseEther("3");
    const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

    const TETHER = await ethers.getContractAt(
        "IERC20",
        TETHERAddress,
        impersonatedSigner
    );

    const UniRouterContract = await ethers.getContractAt(
    "IUniswapV2Router",
    UNIRouter,
    impersonatedSigner,
  );

  await TETHER.approve(UNIRouter, amountTETHER);


  const tetherBalBefore = await TETHER.balanceOf(impersonatedSigner.address);
  const wethBalBefore = await ethers.provider.getBalance(impersonatedSigner.address);
  console.log(
    "=================Before========================================",
  );

  console.log("TETHER Balance before adding liquidity:", ethers.formatUnits(tetherBalBefore, 6));
  console.log("WETH Balance before adding liquidity:", ethers.formatEther(wethBalBefore)); // dkdk

  const transaction = await UniRouterContract.addLiquidityETH(
    TETHERAddress,
    amountTETHER,
    amountTETHERMin,
    amountETHMin,
    impersonatedSigner.address,
    deadline,
    {
      value: ethers.parseEther("4"),
    }
  );

  await transaction.wait();

  const tetherBalAfter = await TETHER.balanceOf(impersonatedSigner);
  const wethBalAfter = await ethers.provider.getBalance(impersonatedSigner);
  console.log(
    "=================After========================================",
  );

  console.log("TETHER Balance before adding liquidity:", ethers.formatUnits(tetherBalAfter, 6));
  console.log("WETH Balance before adding liquidity:", ethers.formatEther(wethBalAfter)); // dkdk

  console.log("Liquidity added successfully!");
  console.log("=========================================================");
  const tetherUsed = tetherBalBefore - tetherBalAfter;
  const wethUsed = wethBalBefore - wethBalAfter;

  console.log("TETHER USED:", ethers.formatUnits(tetherUsed, 6));
  console.log("WETH USED:", ethers.formatUnits(wethUsed, 18));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});