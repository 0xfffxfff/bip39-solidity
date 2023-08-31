import { task } from "hardhat/config";
import { mkdir, writeFile } from "node:fs/promises";

task("render", "Render a Token")
  // .addParam("id", "The ID of the mintpass")
  .setAction(async (taskArgs, hre) => {
    // const chainId = await hre.getChainId();
    const SeedPoems = await hre.deployments.get("SeedPoems");
    const SeedPoemsArtifact = await hre.ethers.getContractAt(
      "SeedPoems",
      SeedPoems.address
    );

    await mkdir("./render", { recursive: true });

    const totalSupply = await SeedPoemsArtifact.totalSupply();
    console.log(`Rendering ${totalSupply.toNumber()} tokens`);
    for (let i = 1; i <= totalSupply.toNumber(); i++) {
      console.log(i, await SeedPoemsArtifact.seeds(i));
      const svg = await SeedPoemsArtifact.renderSVG(i);
      await writeFile(`./render/${i}.svg`, svg);
    }
    console.log("All Done!");
  });
