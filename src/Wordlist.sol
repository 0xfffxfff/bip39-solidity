// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract Wordlist {
    mapping (string => bool) public words;
    string[2048] public wordlist;
    address private deployer;
    bool public finalized;

    constructor() {
        deployer = msg.sender;
        wordlist;
    }

    function commitWords(string[] memory _words, uint256 _index) external {
        require(!finalized, "finalized");
        require(msg.sender == deployer, "only deployer");
        require(_index + _words.length - 1 < 2048, "index too high");

        require(msg.sender == deployer);
        for (uint256 i = 0; i < _words.length; i++) {
            wordlist[_index + i] = _words[i];
            words[_words[i]] = true;
        }
    }

    function finalize() external {
        require(msg.sender == deployer, "only deployer");
        finalized = true;
    }

    function isValidWord(string memory _word) external view returns (bool) {
        return words[_word];
    }

    function isValidSeed(string[] memory _seed) external view returns (bool) {
        if(_seed.length < 3 || _seed.length > 24 || _seed.length % 3 != 0) return false;

        // here be apes

        for (uint i = 0; i < _seed.length; i++) {
            if (!words[_seed[i]]) return false;
        }
        return true;
    }

    function getWordlist() external view returns (string[2048] memory) {
        return wordlist;
    }
}