// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract BIP39 {
    string constant public language = "english";
    string[2048] public wordlist;
    bool public finalized;
    address private deployer;

    constructor() {
        deployer = msg.sender;
    }

    modifier onlyDeployer {
        require(msg.sender == deployer, "only deployer");
        _;
    }

    function commitWords(string[] memory _wordsChunk, uint256 _offset) external onlyDeployer {
        require(!finalized, "finalized");
        require(_offset + _wordsChunk.length - 1 < 2048, "index too high");
        for (uint256 i = 0; i < _wordsChunk.length; i++) {
            wordlist[_offset + i] = _wordsChunk[i];
        }
    }

    function finalizeWords() external onlyDeployer {
        finalized = true;
    }

    function getWordlist() external view returns (string[2048] memory) {
        return wordlist;
    }

    /*//////////////////////////////////////////////////////////////
                                BIP39
    //////////////////////////////////////////////////////////////*/

    function entropyToMnemonic(bytes memory entropy) public view returns (uint[] memory) {
        bytes32 hashedEntropy = sha256(entropy);
        string memory binaryEntropy = "";
        for (uint i = 0; i < entropy.length; i++) {
            binaryEntropy = string(abi.encodePacked(binaryEntropy, uintToBinaryString(uint8(entropy[i]), 8)));
        }
        string memory binaryChecksum = substring(uintToBinaryString(uint256(hashedEntropy), 256), 0, entropy.length * 8 / 4);
        string memory binaryString = string(abi.encodePacked(binaryEntropy, binaryChecksum));

        uint mnemonicLength = (entropy.length * 8 + entropy.length / 4 + 7) / 11;

        uint[] memory mnemonicIndices = new uint[](mnemonicLength);
        for (uint i = 0; i < mnemonicLength; i++) {
            uint index = binaryToUint(substring(binaryString, i * 11, min((i+1) * 11, bytes(binaryString).length)));
            mnemonicIndices[i] = index;
        }
        return mnemonicIndices;
    }


    function entropyToMnemonicString(bytes memory entropy) public view returns (string[] memory) {
        return indicesToWords(entropyToMnemonic(entropy));
    }

    function mnemonicToEntropy(uint[] memory wordIndices) public pure returns (bytes memory) {
        require(wordIndices.length >= 3 && wordIndices.length <= 24 && wordIndices.length % 3 == 0, "Invalid word count");

        uint concatLenBits = wordIndices.length * 11;
        bytes memory concatBits = new bytes(concatLenBits);

        for (uint wordIndex = 0; wordIndex < wordIndices.length; wordIndex++) {
            uint ndx = wordIndices[wordIndex];

            for (uint i = 0; i < 11; i++) {
                bool isOne = (ndx & (1 << (10 - i))) != 0;
                concatBits[(wordIndex * 11) + i] = isOne ? bytes1(uint8(1)) : bytes1(uint8(0));
            }
        }

        uint checksumLengthBits = concatLenBits / 33;
        uint entropyLengthBits = concatLenBits - checksumLengthBits;

        bytes memory entropy = new bytes(entropyLengthBits / 8);
        for (uint i = 0; i < entropy.length; i++) {
            for (uint j = 0; j < 8; j++) {
                if (uint8(concatBits[(i * 8) + j]) == 1) {
                    entropy[i] = bytes1(uint8(entropy[i]) | uint8(1 << (7 - j)));
                }
            }
        }

        bytes32 hashBytes = sha256(entropy);

        for (uint i = 0; i < checksumLengthBits; i++) {
            require(
                uint8(concatBits[entropyLengthBits + i]) == uint8(uint8(hashBytes[i / 8]) >> (7 - i % 8) & 1),
                "Failed checksum"
            );
        }

        return entropy;
    }

    function generateMnemonic(uint256 words) public view returns (uint[] memory) {
        require(words >= 3 && words <= 24 && words % 3 == 0, "Invalid word count");
        bytes memory entropy = generateEntropy(words);
        uint[] memory mnemonicIndices = entropyToMnemonic(entropy);
        return mnemonicIndices;
    }

    function generateMnemonicString(uint256 words) public view returns (string[] memory) {
        return indicesToWords(generateMnemonic(words));
    }

    function indicesToWords(uint256[] memory indices) public view returns (string[] memory) {
        string[] memory words = new string[](indices.length);
        for (uint index; index < indices.length; index++) {
            words[index] = wordlist[indices[index]];
        }
        return words;
    }

    function generateEntropy(uint256 words) public view returns (bytes memory) {
        require(words >= 3 && words <= 24 && words % 3 == 0, "Invalid word count");

        bytes32 totalEntropy = keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp,
            gasleft()
        ));

        uint256 bits = words / 3 * 32;
        uint256 bytesLength = bits / 8;

        bytes memory entropy = new bytes(bytesLength);
        for (uint i = 0; i < bytesLength; i++) {
            entropy[i] = totalEntropy[i];
        }
        return entropy;
    }


    /*//////////////////////////////////////////////////////////////
                                Utility
    //////////////////////////////////////////////////////////////*/

    function substring(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function uintToBinaryString(uint256 x, uint256 length) internal pure returns (string memory) {
        bytes memory result = new bytes(length);
        for (uint i = 0; i < length; i++) {
            uint8 b = uint8(uint(x) >> (length - 1 - i));
            result[i] = b % 2 == 0 ? bytes1(uint8(48)) : bytes1(uint8(49));  // 48 and 49 are '0' and '1' in ASCII
        }
        return string(result);
    }

    function binaryToUint(string memory binaryString) internal pure returns (uint) {
        bytes memory binaryBytes = bytes(binaryString);
        uint result = 0;
        for (uint i = 0; i < binaryBytes.length; i++) {
            if (binaryBytes[i] == '1') {
                result += 2**(binaryBytes.length - i - 1);
            }
        }
        return result;
    }

    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}