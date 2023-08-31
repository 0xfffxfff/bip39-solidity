import { task } from "hardhat/config";

import { wordlists } from "bip39";

task("words:commit", "Commit words").setAction(async (taskArgs, hre) => {
  // const chainId = await hre.getChainId();
  const MnemonicPoem = await hre.deployments.get("SeedPoems");
  const MnemonicPoemArtifact = await hre.ethers.getContractAt(
    "SeedPoems",
    MnemonicPoem.address
  );

  const CHUNKS = 4;
  for (let i = 0; i < CHUNKS; i++) {
    let count = wordlists.english.length / CHUNKS;
    let offset = count * i;
    let chunk = wordlists.english.slice(offset, offset + count);
    await MnemonicPoemArtifact.commitWords(chunk, offset);
  }
  await MnemonicPoemArtifact.finalizeWords();

  console.log("All Done!");
});
