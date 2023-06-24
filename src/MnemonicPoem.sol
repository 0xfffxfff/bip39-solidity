// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./BIP39.sol";
import "./ERC721.sol";
import "hardhat/console.sol";

contract MnemonicPoem is ERC721, BIP39 {

    uint256 public totalSupply;

    constructor() ERC721("Mnemonic Poem", "MNEMO") {
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }

    function mint(uint256 words) public {
        string[] memory mnemonic = generateMnemonic(words);
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function mint(uint256[] memory menmonicIndices) public {
        string[] memory mnemonic = indicesToWords(menmonicIndices);
        bytes memory entropy = mnemonicToEntropy(menmonicIndices);
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }
}