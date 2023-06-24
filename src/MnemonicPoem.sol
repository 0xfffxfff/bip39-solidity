// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./BIP39.sol";
import "./HDWallet.sol";
import "./misc/ERC721.sol";
import "hardhat/console.sol";

contract MnemonicPoem is ERC721, BIP39, HDWallet {

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
    
    function mintExNihilo() public returns (address) {
        // string memory entropy = generateEntropy(24);
        string memory entropy = "2197684e9ffd3e69db5c2c06cbfb639d000aab1ae656d600f9c3a865fcb0e216";
        address addr = generateAddressFromEntropy(entropy);
        return addr;
    }

    function generateAddressFromEntropy(string memory entropy) public view returns (address) {
        bytes memory seed = generateSeedFromEntropy(entropy);
        console.logBytes(seed);
        bytes32 derivedPrivateKey = deriveEthereumPrivateKey(seed);
        bytes memory publicKey = privateKeyToPublicKey(derivedPrivateKey);
        return publicKeyToAddress(publicKey);
    }

}