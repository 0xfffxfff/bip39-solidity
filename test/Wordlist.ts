import { expect } from "chai";
import { ethers } from "hardhat";
import { wordlists } from "bip39";

import { Wordlist, Wordlist__factory } from '../typechain-types';

describe("Wordlist", function () {
  let WordlistContractFactory : Wordlist__factory;
  let wordlist: Wordlist;
  let signers, owner, addr1, addr2, addr3, addrs;

  beforeEach(async function () {
    signers = await ethers.getSigners();
    [owner, addr1, addr2, addr3, ...addrs] = signers;
    WordlistContractFactory = await ethers.getContractFactory("Wordlist");

    wordlist = await WordlistContractFactory.deploy();
    await wordlist.deployed();

    const CHUNKS = 4;
    for (let i = 0; i < CHUNKS; i++) {
      let count = wordlists.english.length / CHUNKS;
      let offset = count * i;
      let chunk = wordlists.english.slice(offset, offset + count);
      await wordlist.commitWords(chunk, offset);
    }
    await wordlist.finalize();
  });

  describe("Deployment", function () {
    it("Should return the correct word list", async function () {
      expect(await wordlist.wordlist(0)).to.equal("abandon");
      expect(await wordlist.getWordlist()).to.have.ordered.members(wordlists.english);
    });

    it("Should check words", async function () {
      expect(await wordlist.isValidWord("rug")).to.equal(true);
      expect(await wordlist.isValidWord("rugger")).to.equal(false);
    });

    it("Should check seeds", async function () {
      // here be apes
      for (let i = 1; i <= 8; i++) {
        let seed = getNFromArray(wordlists.english, i*3);
        console.log(seed.length, seed);
        expect(await wordlist.isValidSeed(seed)).to.equal(true);
      }
      expect(await wordlist.isValidSeed(["dismiss", "leaf"])).to.equal(false);
    });

  });
});

function getNFromArray(array:Array<any>, n:number) {
  const shuffled = array.map(m=>m).sort(() => 0.5 - Math.random());
  return shuffled.slice(0, n)
}