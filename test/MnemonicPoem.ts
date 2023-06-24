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
      expect(await mnemonicPoem.mintExNihilo()).to.not.be.reverted;
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

    it("Should return the correct word list", async function () {
      expect(await mnemonicPoem.wordlist(0)).to.equal("abandon");
      expect(await mnemonicPoem.getWordlist()).to.have.ordered.members(
        wordlists.english
      );
    });

    it("Should match words from index correctly", async function () {
      expect(await mnemonicPoem.wordlist(0)).to.equal("abandon");
      expect(await mnemonicPoem.wordlist(2047)).to.equal("zoo");
      expect(await mnemonicPoem.wordlist(1046)).to.equal("lizard");
    });

    it("Should generate mnemonics", async function () {
      console.log(await mnemonicPoem.generateMnemonic(12));
      console.log(await mnemonicPoem.generateMnemonic(24));
      console.log(await mnemonicPoem.generateMnemonic(3));
    });

    // it("Should check words", async function () {
    //   expect(await mnemonicPoem.isValidWord("rug")).to.equal(true);
    //   expect(await mnemonicPoem.isValidWord("rugger")).to.equal(false);
    //   expect(await mnemonicPoem.isValidWord("abandon")).to.equal(true);
    //   expect(await mnemonicPoem.isValidWord("zone")).to.equal(true);
    //   expect(await mnemonicPoem.isValidWord("zoo")).to.equal(true);
    // });

    it("Should generate a mnemonic from entropy", async function () {
      expect(
        await mnemonicPoem.entropyToMnemonicString(
          "ff29322f8356e3c31759e5b508c65522f50efb7f5d5be050429585c81c7df26b"
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
        await mnemonicPoem.entropyToMnemonicString("05c7f9282242fffb")
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
        expect(await mnemonicPoem.mnemonicToEntropy(indices)).to.not.be
          .reverted;
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
        await expect(
          mnemonicPoem.mnemonicToEntropy(indices)
        ).to.be.revertedWith("Failed checksum");
      }
    });
  });
});
