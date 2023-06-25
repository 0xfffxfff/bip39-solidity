import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { wordlists } from "bip39";

import { BIP39, BIP39__factory } from "../typechain-types";

describe("BIP39", function () {
  let BIP39ContractFactory: BIP39__factory;
  let bip39: BIP39;
  let signers, owner, addr1, addr2, addr3, addrs;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    [owner, addr1, addr2, addr3, ...addrs] = signers;
    BIP39ContractFactory = await ethers.getContractFactory("BIP39");

    bip39 = await BIP39ContractFactory.deploy();
    await bip39.deployed();

    const CHUNKS = 4;
    for (let i = 0; i < CHUNKS; i++) {
      let count = wordlists.english.length / CHUNKS;
      let offset = count * i;
      let chunk = wordlists.english.slice(offset, offset + count);
      await bip39.commitWords(chunk, offset);
    }
    await bip39.finalizeWords();
  });

  describe("Deployment", function () {
    it("Should return the correct word list", async function () {
      expect(await bip39.wordlist(0)).to.equal("abandon");
      expect(await bip39.getWordlist()).to.have.ordered.members(
        wordlists.english
      );
    });

    it("Should match words from index correctly", async function () {
      expect(await bip39.wordlist(0)).to.equal("abandon");
      expect(await bip39.wordlist(2047)).to.equal("zoo");
      expect(await bip39.wordlist(1046)).to.equal("lizard");
    });

    for (let i = 1; i <= 8; i++) {
      it(`Should generate mnemonics with ${
        i * 3
      } words and then verify them`, async function () {
        for (let j = 0; j < 3; j++) {
          const wordCount = i * 3;
          const mnemonic = await bip39.generateMnemonic(wordCount);
          await hre.network.provider.send("hardhat_mine", [
            `0x${(1).toString(16)}`,
            "0xC",
          ]);
          expect(await bip39.mnemonicToEntropy(mnemonic)).to.not.be.reverted;
        }
      });
    }

    it("Should generate a mnemonic from entropy", async function () {
      expect(
        await bip39.entropyToMnemonicString(
          "0xff29322f8356e3c31759e5b508c65522f50efb7f5d5be050429585c81c7df26b"
        )
      ).to.have.ordered.members([
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
      ]);
      expect(
        await bip39.entropyToMnemonicString("0x05c7f9282242fffb")
      ).to.have.ordered.members([
        "alarm",
        "divert",
        "energy",
        "duty",
        "copper",
        "work",
      ]);
    });

    it("Should get entropy from correct seeds", async function () {
      // here be apes
      const correctSeeds = [
        ["lawn", "actual", "brick"],
        [
          "gun",
          "drip",
          "weird",
          "prefer",
          "nasty",
          "adult",
          "course",
          "word",
          "feed",
          "horn",
          "video",
          "wolf",
        ],
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
        ],
      ];
      for (let i = 0; i < correctSeeds.length; i++) {
        const seed = correctSeeds[i];
        const indices = seed.map((w) => wordlists.english.indexOf(w));
        expect(await bip39.mnemonicToEntropy(indices)).to.not.be.reverted;
      }
      const incorrectSeeds = [
        ["brick", "lawn", "zoo"],
        [
          "course",
          "word",
          "feed",
          "horn",
          "gun",
          "drip",
          "weird",
          "prefer",
          "nasty",
          "adult",
          "video",
          "wolf",
        ],
      ];
      for (let i = 0; i < incorrectSeeds.length; i++) {
        const seed = incorrectSeeds[i];
        const indices = seed.map((w) => wordlists.english.indexOf(w));
        await expect(bip39.mnemonicToEntropy(indices)).to.be.revertedWith(
          "Failed checksum"
        );
      }
    });
  });
});
