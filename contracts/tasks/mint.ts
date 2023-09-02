import { task } from "hardhat/config";
import { mkdir, writeFile } from "node:fs/promises";
import { wordlists, generateMnemonic } from "bip39";

task("mint", "Mint a Token")
  .addParam("amount", "Amount of tokens to mint", "1")
  .setAction(async (taskArgs, hre) => {
    // const chainId = await hre.getChainId();
    const MnemonicPoem = await hre.deployments.get("SeedPoems");
    const MnemonicPoemArtifact = await hre.ethers.getContractAt(
      "SeedPoems",
      MnemonicPoem.address
    );

    const amount = parseInt(taskArgs.amount, 10);

    const choices = [
      3, 3, 3, 3, 3, 6, 6, 6, 6, 9, 9, 12, 12, 12, 12, 12, 15, 18, 21, 24, 24,
    ];

    for (let i = 0; i < amount; i++) {
      const wordCount = choices[Math.floor(Math.random() * choices.length)];
      const mnemonicIndices = await MnemonicPoemArtifact["generateMnemonic(uint256)"](
        wordCount
      );
      const mnemonic = mnemonicIndices.map(
        (i) => wordlists.english[i.toNumber()]
      );

      console.log(`Minting: ${mnemonic.join(" ")}`);

      await MnemonicPoemArtifact.mint(mnemonicIndices, {
        value: hre.ethers.utils.parseEther("0.03")/*.mul(wordCount.toString())*/,
      });
    }
    console.log(`All Done!`);
  });
