import { task } from "hardhat/config";
import { mkdir, writeFile } from "node:fs/promises";

task("render", "Render a Token")
  // .addParam("id", "The ID of the mintpass")
  .setAction(async (taskArgs, hre) => {
    // const chainId = await hre.getChainId();
    const MnemonicPoem = await hre.deployments.get("MnemonicPoem");
    const MnemonicPoemArtifact = await hre.ethers.getContractAt(
      "MnemonicPoem",
      MnemonicPoem.address
    );

    await mkdir("./render", { recursive: true });

    const totalSupply = await MnemonicPoemArtifact.totalSupply();
    console.log(await MnemonicPoemArtifact.mnemonics(1));
    console.log(totalSupply.toNumber());
    for (let i = 1; i <= totalSupply.toNumber(); i++) {
      const svg = await MnemonicPoemArtifact.renderSVG(i);
      await writeFile(`./render/${i}.svg`, svg);
    }
    console.log("All Done!");
  });
