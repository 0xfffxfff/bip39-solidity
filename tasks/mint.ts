import { task } from "hardhat/config";
import { mkdir, writeFile } from "node:fs/promises";
import { wordlists, generateMnemonic } from "bip39";

task("mint", "Mint a Token")
  // .addParam("id", "The ID of the mintpass")
  .setAction(async (taskArgs, hre) => {
    // const chainId = await hre.getChainId();
    const MnemonicPoem = await hre.deployments.get("MnemonicPoem");
    const MnemonicPoemArtifact = await hre.ethers.getContractAt(
      "MnemonicPoem",
      MnemonicPoem.address
    );

    const wordCount = 3; //(Math.floor(Math.random() * 8) + 1) * 3;
    const mnemonicIndices = await MnemonicPoemArtifact.generateMnemonic(
      wordCount
    );
    const mnemonic = mnemonicIndices.map(
      (i) => wordlists.english[i.toNumber()]
    );

    console.log(`Minting: ${mnemonic.join(" ")}`);

    await MnemonicPoemArtifact.mint(mnemonicIndices, {
      value: hre.ethers.utils.parseEther("0.01").mul(wordCount.toString()),
    });

    console.log(`All Done!`);
  });
