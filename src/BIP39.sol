// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract BIP39 {

    string[2048] public wordlist;
    string public language = "english";
    bool public finalized;
    address private deployer;

    constructor() {
        deployer = msg.sender;
        wordlist;
    }

    function commitWords(string[] memory _wordsChunk, uint256 _offset) external {
        require(msg.sender == deployer, "only deployer");
        require(!finalized, "finalized");
        require(_offset + _wordsChunk.length - 1 < 2048, "index too high");

        require(msg.sender == deployer);
        for (uint256 i = 0; i < _wordsChunk.length; i++) {
            wordlist[_offset + i] = _wordsChunk[i];
        }
    }

    function finalizeWords() external {
        require(msg.sender == deployer, "only deployer");
        finalized = true;
    }

    function getWordlist() external view returns (string[2048] memory) {
        return wordlist;
    }

    /*//////////////////////////////////////////////////////////////
                                BIP39
    //////////////////////////////////////////////////////////////*/

    function entropyToMnemonic(string memory hexEntropy) public pure returns (uint[] memory) {
        bytes memory entropy = hexStrToBytes(hexEntropy);
        bytes32 hashedEntropy = sha256(entropy);

        string memory binaryEntropy = toBinaryString(uint256(bytesToBytes32(entropy)));
        string memory binaryChecksum = substring(toBinaryString(uint256(hashedEntropy)), 0, entropy.length * 8 / 32);
        string memory binaryString = string(abi.encodePacked(binaryEntropy, binaryChecksum));

        // Each word in mnemonic is represented by 11 bits.
        uint mnemonicLength = (entropy.length * 8 + entropy.length * 8 / 32) / 11;

        uint[] memory mnemonicIndices = new uint[](mnemonicLength);
        for (uint i = 0; i < mnemonicLength; i++) {
            uint index = binaryToUint(substring(binaryString, i * 11, (i+1) * 11));
            mnemonicIndices[i] = index;
        }

        return mnemonicIndices;
    }
    function entropyToMnemonicString(string memory hexEntropy) public view returns (string[] memory) {
        return indicesToWords(entropyToMnemonic(hexEntropy));
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

    function generateMnemonic(uint256 words) public view returns (string[] memory) {
        require(words >= 3 && words <= 24 && words % 3 == 0, "Invalid word count");
        string memory entropy = generateEntropy(words);
        uint[] memory mnemonicIndices = entropyToMnemonic(entropy);
        return indicesToWords(mnemonicIndices);
    }

    function indicesToWords(uint256[] memory indices) public view returns (string[] memory) {
        string[] memory words = new string[](indices.length);
        for (uint index; index < indices.length; index++) {
            words[index] = wordlist[indices[index]];
        }
        return words;
    }

    function generateEntropy(uint256 words) public view returns (string memory) {
        require(words >= 3 && words <= 24 && words % 3 == 0, "Invalid word count");

        bytes32 entropy = keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp,
            gasleft()
        ));
        string memory hexEntropy = bytesToHexString(abi.encodePacked(entropy));

        uint256 chars = words * 8 / 3;
        return substring(hexEntropy, 0, chars);
    }


    /*//////////////////////////////////////////////////////////////
                                Utility
    //////////////////////////////////////////////////////////////*/

    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function toBinaryString(uint256 x) public pure returns (string memory) {
        string memory result = "";
        for (uint i = 0; i < 256; i++) {
            uint8 b = uint8(uint(x) >> i);
            string memory s = b % 2 == 0 ? "0" : "1";
            result = string(abi.encodePacked(s, result));
        }
        return result;
    }


    function bytesToBytes32(bytes memory source) internal pure returns (bytes32 result) {
        if (source.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function hexStrToBytes(string memory _hexStr) internal pure returns (bytes memory) {
        require(bytes(_hexStr).length % 2 == 0, "Invalid hexadecimal string");
        bytes memory bytesArray = new bytes(bytes(_hexStr).length / 2);
        for (uint i = 0; i < bytesArray.length; i++) {
            bytesArray[i] = bytes1(uint8(_parseNibble(_hexStr, i*2) * 16 + _parseNibble(_hexStr, i*2 + 1)));
        }
        return bytesArray;
    }

    function _parseNibble(string memory _hexChar, uint _index) internal pure returns (uint8) {
        uint8 val = uint8(bytes(_hexChar)[_index]);
        if (val >= uint8(bytes('0')[0]) && val <= uint8(bytes('9')[0])) {
            return val - uint8(bytes('0')[0]);
        }
        if (val >= uint8(bytes('a')[0]) && val <= uint8(bytes('f')[0])) {
            return 10 + val - uint8(bytes('a')[0]);
        }
        if (val >= uint8(bytes('A')[0]) && val <= uint8(bytes('F')[0])) {
            return 10 + val - uint8(bytes('A')[0]);
        }
        revert("Invalid hexadecimal character!");
    }

    function binaryToUint(string memory binaryString) public pure returns (uint) {
        bytes memory binaryBytes = bytes(binaryString);
        uint result = 0;
        for (uint i = 0; i < binaryBytes.length; i++) {
            if (binaryBytes[i] == '1') {
                result += 2**(binaryBytes.length - i - 1);
            }
        }
        return result;
    }

    function uintToHexString(uint256 value) internal pure returns(string memory) {
        bytes32 valueBytes32 = bytes32(value);
        bytes memory byteArray = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            byteArray[i*2] = bytes1(_getHexChar(uint8(valueBytes32[i] >> 4)));
            byteArray[i*2+1] = bytes1(_getHexChar(uint8(valueBytes32[i] & 0x0F)));
        }
        return string(byteArray);
    }

    function _getHexChar(uint8 value) internal pure returns (bytes1) {
        return value < 10 ? bytes1(uint8(value) + 0x30) : bytes1(uint8(value - 10) + 0x61);
    }

    function bytesToHexString(bytes memory data) internal pure returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 * data.length);
        for (uint i = 0; i < data.length; i++) {
            str[i*2] = alphabet[uint(uint8(data[i] >> 4))];
            str[1+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

}