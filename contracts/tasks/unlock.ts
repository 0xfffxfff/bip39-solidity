import { task } from "hardhat/config";
import { mkdir, writeFile } from "node:fs/promises";
import { wordlists, generateMnemonic } from "bip39";

task("unlock", "Unlock minting")
  // .addParam("id", "The ID of the mintpass")
  .setAction(async (taskArgs, hre) => {
    // const chainId = await hre.getChainId();
    const MnemonicPoem = await hre.deployments.get("SeedPoems");
    const MnemonicPoemArtifact = await hre.ethers.getContractAt(
      "SeedPoems",
      MnemonicPoem.address
    );

    await MnemonicPoemArtifact.lock(false);

    console.log(`All Done!`);
  });
