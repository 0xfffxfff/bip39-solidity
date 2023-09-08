// License: MIT
pragma solidity ^0.8.0;

import "./EllipticCurve.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./SHA3_512.sol";

contract BIP44HDWallet {

    uint256 public constant GX =
        0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 public constant GY =
        0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint256 public constant AA = 0;
    uint256 public constant BB = 7;
    uint256 public constant PP =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;


    function generateSeedFromEntropy(string memory entropy) internal view returns (bytes memory) {
        // Creating a salt using the entropy itself (as per BIP39, it's "mnemonic" + passphrase)
        string memory salt = string(abi.encodePacked("mnemonic", entropy));

        // Call the PBKDF2 function
        bytes memory seed = pbkdf2_sha512(bytes(entropy), bytes(salt), 512, 2048);
        return seed;
    }

    function deriveEthereumPrivateKey(bytes memory seed) internal pure returns (bytes32) {
        return sha256(seed);
    }

    // This is good
    function privateKeyToPublicKey(bytes32 privateKey) internal pure returns (bytes memory) {
        (uint qx, uint qy) = EllipticCurve.ecMul(uint(privateKey), GX, GY, AA, PP);
        // Combine the prefix and the two coordinates (d*P in affine coordinates) into one byte array
        bytes memory publicKey = new bytes(65);
        publicKey[0] = 0x04;
        for (uint8 i = 0; i < 32; i++) {
            publicKey[i + 1] = bytes32(qx)[31 - i];
            publicKey[33 + i] = bytes32(qy)[31 - i];
        }

        return publicKey;
    }

    function publicKeyToAddress(bytes memory publicKey) internal pure returns (address) {
        bytes32 publicKeySHA = sha256(publicKey);
        bytes20 publicKeyRIPEMD = ripemd160(abi.encodePacked(publicKeySHA));
        return address(uint160(publicKeyRIPEMD));
    }

    function xor(bytes memory _a, bytes memory _b) internal pure returns (bytes memory) {
        require(_a.length == _b.length, "Length mismatch in XOR inputs");
        bytes memory result = new bytes(_a.length);
        for(uint i = 0; i < _a.length; i++) {
            result[i] = bytes1(uint8(_a[i]) ^ uint8(_b[i]));
        }
        return result;
    }

    function toBytes64(bytes memory data) public pure returns (bytes memory) {
        require(data.length <= 64, "Input data too long");
        bytes memory b64 = new bytes(64);
        for(uint i=0; i<data.length; i++) {
            b64[i] = data[i];
        }
        return b64;
    }

    function hmacsha3_512(bytes memory key, bytes memory message) public view returns (bytes memory) {
        require(key.length >= 64, "Key must be at least 64 bytes long");
        bytes memory keyl = new bytes(64);
        bytes memory keyr = new bytes(64);
        bytes memory ipad = hex"36363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636";
        bytes memory opad = hex"5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c5c";

        // First, create the inner hash.
        // XOR key with ipad
        for (uint i = 0; i < 64; i++) {
            bytes1 keyByte = i < key.length ? key[i] : bytes1(0);
            keyl[i] = bytes1(uint8(keyByte) ^ uint8(ipad[i]));
        }

        // Concatenate the XOR'd key with the message
        bytes memory innerMessage = concat(keyl, message);

        // Hash the inner message
        uint32[16] memory innerHash = SHA3_512.sha3_512(toUint64Array8(innerMessage));

        // Now, create the outer hash.
        // XOR key with opad
        for (uint i = 0; i < 64; i++) {
            keyr[i] = bytes1(uint8(key[i]) ^ uint8(opad[i]));
        }

        // Concatenate the XOR'd key with the inner hash
        bytes memory outerMessage = concat(keyr, uint32Array16toByteArray(innerHash));

        // Hash the outer message
        uint32[16] memory outerHash = SHA3_512.sha3_512(toUint64Array8(outerMessage));

        // The result of the HMAC operation is the outer hash
        return uint32Array16toByteArray(outerHash);
    }

    /// PBKDF2 hash = hmacsha3_512 and dklen being a multiple of 64 not larger than 512
    function pbkdf2_sha512(bytes memory key, bytes memory salt, uint dklen, uint c) public view returns (bytes memory) {
        bytes memory message = new bytes(salt.length + 4);
        for (uint i = 0; i < salt.length; i++) {
            message[i] = salt[i];
        }
        bytes memory r = new bytes(dklen);
        for (uint i = 0; i * 64 < dklen; i++) {
            // Set the last four bytes to the big-endian representation of i + 1
            for (uint j = 0; j < 4; j++) {
                message[message.length - j - 1] = bytes1(uint8((i + 1) >> (8 * j)));
            }

            // Apply the pseudorandom function c times for each block of output
            bytes memory u = hmacsha3_512(key, message);
            bytes memory f = u;
            for (uint j = 1; j < c; j++) {
                u = hmacsha3_512(key, u);
                for (uint k = 0; k < 64; k++) {
                    f[k] ^= u[k];
                }
            }

            // Copy the block of output to the result
            for (uint j = 0; j < 64 && (i * 64 + j) < dklen; j++) {
                r[i * 64 + j] = f[j];
            }
        }
        return r;
    }


   function concat(bytes memory a, bytes memory b) pure private returns (bytes memory) {
        bytes memory result = new bytes(a.length + b.length);
        for(uint i = 0; i < a.length; i++) {
            result[i] = a[i];
        }
        for(uint i = 0; i < b.length; i++) {
            result[i + a.length] = b[i];
        }
        return result;
    }

    function toUint64Array8(bytes memory input) pure private returns (uint64[8] memory) {
        require(input.length >= 64, "Input bytes length should be at least 64");
        uint64[8] memory output;
        for(uint i = 0; i < output.length; i++) {
            uint64 value;
            assembly {
                value := mload(add(input, add(32, mul(i, 8))))
            }
            output[i] = value;
        }
        return output;
    }

    function toUint32Array16(bytes memory input) pure private returns (uint32[16] memory) {
        require(input.length >= 64, "Input bytes length should be at least 64");
        uint32[16] memory output;
        for(uint i = 0; i < output.length; i++) {
            uint32 value;
            assembly {
                value := mload(add(input, add(32, mul(i, 4))))
            }
            output[i] = value;
        }
        return output;
    }

    function uint32Array16toByteArray(uint32[16] memory input) pure private returns (bytes memory) {
        bytes memory output = new bytes(16 * 4);
        for(uint i = 0; i < 16; i++) {
            uint32 value = input[i];
            assembly {
                mstore(add(output, add(32, mul(i, 4))), value)
            }
        }
        return output;
    }

}