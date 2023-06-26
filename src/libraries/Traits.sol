// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Util} from "./Util.sol";

library Traits {
    /*//////////////////////////////////////////////////////////////
                                 Colors
    //////////////////////////////////////////////////////////////*/

    function colorTrait(
        string[] memory words,
        bytes memory entropy
    ) internal pure returns (string memory) {
        string[3] memory color = colorType(words, entropy);
        return color[0];
    }

    function colorType(
        string[] memory words,
        bytes memory entropy
    ) internal pure returns (string[3] memory) {
        uint256 colorRarity = _rarity(entropy, "color") % 20;
        if (colorRarity < 1) return ["Blue", "#0007B7", "#FFFFFF"];
        else if (colorRarity < 2) return ["Gray", "#E0E0E0", "#000000"];
        else if (colorRarity < 3) return ["Petrol", "#467C73", "#000000"];
        else if (colorRarity < 4) return ["Charcoal", "#36414F", "#FFFFFF"];
        else if (colorRarity < 5) return ["Mint", "#ECFFB8", "#000000"];
        else if (colorRarity < 6) return ["Marine", "#74FFE6", "#000000"];
        else if (colorRarity < 7) return ["Purple", "#5A00CD", "#FFFFFF"];
        else if (colorRarity < 8) return ["Pink", "#F89EE4", "#FFFFFF"];
        else if (colorRarity < 9) return ["Yellow", "#FFD600", "#000000"];
        else if (colorRarity < 10) return ["Red", "#E81C10", "#FFFFFF"];
        else if (colorRarity < 11) return ["Brown", "#402F2F", "#FFFFFF"];
        else if (colorRarity < 12) return ["Beige", "#D3CFBD", "#FFFFFF"];
        else if (colorRarity < 13) return ["Sky", "#81E1FF", "#FFFFFF"];
        else if (colorRarity < 14) return ["Orange", "#FF9C54", "#FFFFFF"];
        else if (colorRarity < 15) return ["Green", "#254A2E", "#FFFFFF"];
        else if (colorRarity < 16) return ["White", "#FFFFFF", "#000000"];
        else return ["Void", "#000000", "#FFFFFF"];
    }

    function backgroundColor(
        string[] memory words,
        bytes memory entropy
    ) internal pure returns (string memory) {
        string[3] memory color = colorType(words, entropy);
        return color[1];
    }

    function textColor(
        string[] memory words,
        bytes memory entropy
    ) internal pure returns (string memory) {
        string[3] memory color = colorType(words, entropy);
        return color[2];
    }

    /*//////////////////////////////////////////////////////////////
                                 TRAITS
    //////////////////////////////////////////////////////////////*/

    function attributes(
        string[] memory words,
        bytes memory entropy
    ) internal pure returns (string memory) {
        string memory result = "[";
        result = string.concat(
            result,
            _attribute("Color", colorTrait(words, entropy)),
            _attribute("Words", Util.uint256ToString(words.length))
        );
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

    function _rarity(
        bytes memory _seed,
        string memory _salt
    ) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(_seed, _salt))) % 100;
    }
}
