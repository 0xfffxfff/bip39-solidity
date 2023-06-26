// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Metadata} from "./Metadata.sol";
import {Util} from "./Util.sol";
import {Traits} from "./Traits.sol";
import {Background} from "./Background.sol";
import {TextBody} from "./TextBody.sol";
import {TextLine} from "./TextLine.sol";
import {TextEdition} from "./TextEdition.sol";
import {TextOf} from "./TextOf.sol";
import {Traits} from "./Traits.sol";
import {SVG} from "./SVG.sol";

/// @notice Adopted from Bibos (0xf528e3381372c43f5e8a55b3e6c252e32f1a26e4)
library Render {
    string public constant description = "Mnemonic Poems";

    /*//////////////////////////////////////////////////////////////
                                TOKENURI
    //////////////////////////////////////////////////////////////*/

    function tokenURI(
        uint256 _tokenId,
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) internal pure returns (string memory) {
        string memory wordsStr = words[0];
        for (uint i = 1; i < words.length; i++) {
            wordsStr = string(abi.encodePacked(wordsStr, " ", words[i]));
        }
        return
            Metadata.encodeMetadata({
                _tokenId: _tokenId,
                _name: _name(_tokenId),
                _description: wordsStr,
                _svg: _svg(_tokenId, words, base64font)
            });
    }

    function renderSVG(
        uint256 _tokenId,
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) internal pure returns (string memory) {
        return _svg(_tokenId, words, base64font);
    }

    function renderSVGBase64(
        uint256 _tokenId,
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) internal pure returns (string memory) {
        return Metadata._encodeSVG(_svg(_tokenId, words, base64font));
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _svg(
        uint256 _tokenId,
        string[] memory words,
        string memory base64font
    ) internal pure returns (string memory) {
        return
            SVG.element(
                "svg",
                SVG.svgAttributes(),
                string.concat(
                    "<defs><style>",
                    '@font-face {font-family: "Bebas Neue";src: url("',
                    base64font,
                    '");}',
                    "text {text-transform: uppercase;"
                    "}</style></defs>"
                ),
                Background.render(),
                _renderText(_tokenId, words)
            );
    }

    function _renderText(
        uint256 _tokenId,
        string[] memory mnemonic
    ) public pure returns (string memory) {
        uint256 wordCount = mnemonic.length;
        uint8 charsPerLine = 24;
        if (wordCount == 21) charsPerLine = 22;
        else if (wordCount == 18) charsPerLine = 20;
        else if (wordCount == 15) charsPerLine = 18;
        else if (wordCount == 12) charsPerLine = 17;
        else if (wordCount == 9) charsPerLine = 15;
        else if (wordCount == 6) charsPerLine = 12;
        else if (wordCount == 3) charsPerLine = 9;
        else if (wordCount != 24) revert("Invalid words per line");

        string[] memory tempLines = new string[](wordCount); // worst-case scenario, one word per line
        string memory line;
        uint256 lineCount = 0;

        for (uint256 i = 0; i < mnemonic.length; i++) {
            string memory nextWord = mnemonic[i];
            // the +1 accounts for the space
            if (
                bytes(line).length != 0 &&
                bytes(line).length + bytes(nextWord).length + 1 > charsPerLine
            ) {
                tempLines[lineCount] = line;
                lineCount++;
                line = nextWord;
            } else {
                if (bytes(line).length != 0) {
                    line = string(abi.encodePacked(line, " ", nextWord));
                } else {
                    line = nextWord;
                }
            }

            if (i == mnemonic.length - 1) {
                tempLines[lineCount] = line;
            }
        }

        //  3 words: fontSize 125 / measured yDistance 120 at lineHeight 96%
        //  6 words: fontSize 93  / measured yDistance 93 at lineHeight 100%
        //  9 words: fontSize 75  / measured yDistance 81 at lineHeight 108%
        // 12 words: fontSize 75  / measured yDistance 84 at lineHeight 112%
        // 15 words: fontSize 65  / measured yDistance 76 at lineHeight 116%
        // 18 words: fontSize 62  / measured yDistance 71 at lineHeight 118%
        // 21 words: fontSize 57  / measured yDistance 67 at lineHeight 118%
        // 24 words: fontSize 55  / measured yDistance 66 at lineHeight 120%
        string memory fontSize = "125";
        uint256 yDistance = 120;
        if (wordCount == 6) {
            fontSize = "93";
            yDistance = 93;
        } else if (wordCount == 9) {
            fontSize = "75";
            yDistance = 81;
        } else if (wordCount == 12) {
            fontSize = "75";
            yDistance = 84;
        } else if (wordCount == 15) {
            fontSize = "65";
            yDistance = 76;
        } else if (wordCount == 18) {
            fontSize = "62";
            yDistance = 71;
        } else if (wordCount == 21) {
            fontSize = "57";
            yDistance = 67;
        } else if (wordCount == 24) {
            fontSize = "55";
            yDistance = 66;
        }

        uint256 topOffset = 444 - (lineCount * yDistance) / 2;

        bytes memory svgTexts;
        for (uint256 i = 0; i <= lineCount; i++) {
            svgTexts = abi.encodePacked(
                svgTexts,
                TextLine.render(
                    tempLines[i],
                    topOffset + (i * yDistance),
                    fontSize
                )
            );
        }

        return SVG.element("g", "", string(svgTexts));
    }

    function _name(uint256 _tokenId) internal pure returns (string memory) {
        return
            string.concat("Mnemonic Poem ", Util.uint256ToString(_tokenId, 3));
    }
}
