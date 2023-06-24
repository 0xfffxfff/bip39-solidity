import { expect } from "chai";
import { ethers } from "hardhat";
import { wordlists } from "bip39";

import { MnemonicPoem, MnemonicPoem__factory } from "../typechain-types";

describe("MnemonicPoem", function () {
  let MnemonicPoemContractFactory: MnemonicPoem__factory;
  let mnemonicPoem: MnemonicPoem;
  let signers, owner, addr1, addr2, addr3, addrs;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    [owner, addr1, addr2, addr3, ...addrs] = signers;
    MnemonicPoemContractFactory = await ethers.getContractFactory(
      "MnemonicPoem"
    );

    mnemonicPoem = await MnemonicPoemContractFactory.deploy();
    await mnemonicPoem.deployed();

    const CHUNKS = 4;
    for (let i = 0; i < CHUNKS; i++) {
      let count = wordlists.english.length / CHUNKS;
      let offset = count * i;
      let chunk = wordlists.english.slice(offset, offset + count);
      await mnemonicPoem.commitWords(chunk, offset);
    }
    await mnemonicPoem.finalize();
  });

  describe("Deployment", function () {
    it("Should allow to mint a mnemonic", async function () {
      expect(await mnemonicPoem["mint(uint256)"](24)).to.not.be.reverted;
      expect(await mnemonicPoem["mint(uint256)"](12)).to.not.be.reverted;
      expect(await mnemonicPoem["mint(uint256)"](3)).to.not.be.reverted;
      expect(
        await mnemonicPoem["mint(uint256[])"](
          [
            "you",
            "end",
            "message",
            "allow",
            "hotel",
            "thunder",
            "frost",
            "device",
            "relax",
            "economy",
            "next",
            "echo",
            "extend",
            "laundry",
            "word",
            "problem",
            "theory",
            "link",
            "pistol",
            "argue",
            "limb",
            "discover",
            "situate",
            "initial",
          ].map((word) => wordlists.english.indexOf(word))
        )
      ).to.not.be.reverted;
      expect(
        await mnemonicPoem["mint(uint256[])"](
          ["lawn", "actual", "brick"].map((word) =>
            wordlists.english.indexOf(word)
          )
        )
      ).to.not.be.reverted;
    });
  });
});
