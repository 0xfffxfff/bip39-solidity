import { expect } from "chai";
import { ethers } from "hardhat";
import { wordlists } from "bip39";

import {
  SeedPoems,
  SeedPoems__factory,
  Render,
  Render__factory,
} from "../typechain-types";
import { Signer } from "ethers";

describe("SeedPoems", function () {
  let SeedPoemsContractFactory: SeedPoems__factory;
  let seedPoem: SeedPoems;
  let RenderContractFactory: Render__factory;
  let render: Render;
  let signers: Signer[], owner: Signer, addr1: Signer, addr2: Signer, addr3: Signer, addrs: Signer[];

  beforeEach(async function () {
    signers = await ethers.getSigners();
    [owner, addr1, addr2, addr3, ...addrs] = signers;

    RenderContractFactory = await ethers.getContractFactory("Render");
    render = await RenderContractFactory.deploy();

    SeedPoemsContractFactory = await ethers.getContractFactory("SeedPoems", {
      libraries: { Render: render.address },
    });
    seedPoem = await SeedPoemsContractFactory.deploy();

    await seedPoem.deployed();

    const CHUNKS = 4;
    for (let i = 0; i < CHUNKS; i++) {
      let count = wordlists.english.length / CHUNKS;
      let offset = count * i;
      let chunk = wordlists.english.slice(offset, offset + count);
      await seedPoem.commitWords(chunk, offset);
    }
    await seedPoem.finalizeWords();
  });

  describe("Mintable", function () {
    it("Should fail to mint while paused", async function () {
      await expect(seedPoem.mint([])).to.be.revertedWithCustomError(seedPoem, 'Paused');
      await seedPoem.setPause(false);
    });
    it("Should allow public to mint a mnemonic", async function () {
      await expect(seedPoem.mint([])).to.be.revertedWithCustomError(seedPoem, 'Paused');
      await seedPoem.setPause(false);
      expect(
        await seedPoem.connect(addr2).mint(
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
            value: ethers.utils.parseEther("0.03")//.mul("24"),
          }
        )
      ).to.not.be.reverted;
      expect(
        await seedPoem.connect(addr3).mint(
          ["lawn", "actual", "brick"].map((word) =>
            wordlists.english.indexOf(word)
          ),
          {
            value: ethers.utils.parseEther("0.03")//.mul("3"),
          }
        )
      ).to.not.be.reverted;
    });
    it("Should allow artist to mint a mnemonic", async function () {
      await expect(
        seedPoem.connect(addr2).mintArtist(
          ["lawn", "actual", "brick"].map((word) => wordlists.english.indexOf(word)),
          await owner.getAddress(),
          false,
          {
            value: ethers.utils.parseEther("0.03")//.mul("24"),
          }
        )
      ).to.revertedWithCustomError(seedPoem, 'Unauthorized');
      expect(
        await seedPoem.connect(owner).mintArtist(
          ["lawn", "actual", "brick"].map((word) =>
            wordlists.english.indexOf(word)
          ),
          await owner.getAddress(),
          false,
          {
            value: ethers.utils.parseEther("0.03")//.mul("3"),
          }
        )
      ).to.not.be.reverted;
    });
  });
});
