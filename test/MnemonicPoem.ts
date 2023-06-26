import { expect } from "chai";
import { ethers } from "hardhat";
import { wordlists } from "bip39";

import {
  MnemonicPoem,
  MnemonicPoem__factory,
  Render,
  Render__factory,
} from "../typechain-types";

describe("MnemonicPoem", function () {
  let MnemonicPoemContractFactory: MnemonicPoem__factory;
  let mnemonicPoem: MnemonicPoem;
  let RenderContractFactory: Render__factory;
  let render: Render;
  let signers, owner, addr1, addr2, addr3, addrs;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    [owner, addr1, addr2, addr3, ...addrs] = signers;

    RenderContractFactory = await ethers.getContractFactory("Render");
    render = await RenderContractFactory.deploy();

    MnemonicPoemContractFactory = await ethers.getContractFactory(
      "MnemonicPoem",
      { libraries: { Render: render.address } }
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
    await mnemonicPoem.finalizeWords();
  });

  describe("Deployment", function () {
    it("Should allow to mint a mnemonic", async function () {
      await expect(mnemonicPoem.mint([])).to.be.revertedWith("LOCKED");
      await mnemonicPoem.lock(false);
      expect(
        await mnemonicPoem.mint(
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
          ].map((word) => wordlists.english.indexOf(word)),
          {
            value: ethers.utils.parseEther("0.01").mul("24"),
          }
        )
      ).to.not.be.reverted;
      expect(
        await mnemonicPoem.mint(
          ["lawn", "actual", "brick"].map((word) =>
            wordlists.english.indexOf(word)
          ),
          {
            value: ethers.utils.parseEther("0.01").mul("3"),
          }
        )
      ).to.not.be.reverted;
    });
  });
});
