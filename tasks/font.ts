import { task } from "hardhat/config";

task("font", "Set Font").setAction(async (taskArgs, hre) => {
  const MnemonicPoem = await hre.deployments.get("MnemonicPoem");
  const MnemonicPoemArtifact = await hre.ethers.getContractAt(
    "MnemonicPoem",
    MnemonicPoem.address
  );

  const bebasNeueOnlyLowercaseAndSpace =
    "data:application/font-woff2;charset=utf-8;base64,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";

  await MnemonicPoemArtifact.setFont(bebasNeueOnlyLowercaseAndSpace);

  console.log("All Done!");
});
