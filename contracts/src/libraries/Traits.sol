// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Util} from "./Util.sol";
import "../misc/Editions.sol";

library Traits {

    function distortionTrait(
        bytes memory entropy
    ) internal pure returns (string memory) {
        uint256 distortion = distortionType(entropy);
        return distortion == 1 ? "Low" : distortion == 2 ? "Medium" : "High";
    }

    function distortionType(
        bytes memory entropy
    ) internal pure returns (uint256) {
        return (_rarity(entropy, "distortion") % 3) + 1; // 1-3
    }

    function colorTrait(
        string[] memory words,
        bytes memory entropy,
        bool bound,
        Edition edition
    ) internal pure returns (string memory) {
        string[3] memory color = colorType(words, entropy, bound, edition);
        return color[0];
    }

    function colorType(
        string[] memory words,
        bytes memory entropy,
        bool bound,
        Edition edition
    ) internal pure returns (string[3] memory) {
        return ["Void", "#F9F9F9", "#000000"];
    }

    function backgroundColor(
        string[] memory words,
        bytes memory entropy,
        bool bound,
        Edition edition
    ) internal pure returns (string memory) {
        string[3] memory color = colorType(words, entropy, bound, edition);
        return color[1];
    }

    function textColor(
        string[] memory words,
        bytes memory entropy,
        bool bound,
        Edition edition
    ) internal pure returns (string memory) {
        string[3] memory color = colorType(words, entropy, bound, edition);
        return color[2];
    }

    function textRotation(
        string[] memory words,
        bytes memory entropy
    ) internal pure returns (string memory) {
        uint256 rotationSeed = _rarity(entropy, "rotation");
        bool isPositive = rotationSeed % 2 == 0;
        uint256 degrees = (rotationSeed / 10) % 6;
        uint256 float = (rotationSeed / 100) % 1000;
        return
            string.concat(
                isPositive ? "" : "-",
                Util.uint256ToString(degrees),
                ".",
                Util.uint256ToString(float)
            );
    }

    /*//////////////////////////////////////////////////////////////
                                 TRAITS
    //////////////////////////////////////////////////////////////*/

    function attributes(
        string[] memory words,
        bytes memory entropy,
        bool bound,
        Edition edition
    ) internal pure returns (string memory) {
        string memory result = "[";
        result = string.concat(
            result,
            _attribute("Words", Util.uint256ToString(words.length)),
            _attribute("Edition", edition == Edition.Curated ? "Curated" : "Public")
        );
        if (bound) {
            result = string.concat(
                result,
                _attribute("Bound")
            );
        }
        return string.concat(result, "]");
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _attribute(
        string memory _traitType,
        string memory _value
    ) internal pure returns (string memory) {
        return
            string.concat(
                "{",
                Util.keyValue("trait_type", _traitType),
                ",",
                Util.keyValue("value", _value),
                "}"
            );
    }

    function _attribute(
        string memory _value
    ) internal pure returns (string memory) {
        return
            string.concat(
                "{",
                Util.keyValue("value", _value),
                "}"
            );
    }

    function _rarity(
        bytes memory _seed,
        string memory _salt
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_seed, _salt)));
    }
}
