// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Metadata} from "./Metadata.sol";
import {Util} from "./Util.sol";
import {Traits} from "./Traits.sol";
import {Background} from "./Background.sol";
import {TextLine} from "./TextLine.sol";
import {Traits} from "./Traits.sol";
import {SVG} from "./SVG.sol";
import {Effect} from "./Effect.sol";

library Render {
    string public constant description = "Seed Poems";

    /*//////////////////////////////////////////////////////////////
                                TOKENURI
    //////////////////////////////////////////////////////////////*/

    function tokenURI(
        uint256 _tokenId,
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) external pure returns (string memory) {
        string memory wordString = words[0];
        for (uint i = 1; i < words.length; i++) {
            wordString = string.concat(wordString, " ", words[i]);
        }
        return
            Metadata.encodeMetadata({
                _tokenId: _tokenId,
                _name: wordString,
                _description: wordString,
                _attributes: Traits.attributes(words, entropy),
                _backgroundColor: Traits.backgroundColor(words, entropy),
                _svg: _svg(words, entropy, base64font, false),
                _animation: _svg(words, entropy, base64font, true)
            });
    }

    function renderSVG(
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) external pure returns (string memory) {
        return _svg(words, entropy, base64font, true);
    }

    function renderSVGBase64(
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) external pure returns (string memory) {
        return Metadata._encodeSVG(_svg(words, entropy, base64font, true));
    }

    function renderSVGstatic(
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) external pure returns (string memory) {
        return _svg(words, entropy, base64font, false);
    }

    function renderSVGBase64static(
        string[] memory words,
        bytes memory entropy,
        string memory base64font
    ) external pure returns (string memory) {
        return Metadata._encodeSVG(_svg(words, entropy, base64font, false));
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _svg(
        string[] memory words,
        bytes memory entropy,
        string memory base64font,
        bool animate
    ) internal pure returns (string memory) {
        return
            SVG.element(
                "svg",
                SVG.svgAttributes(),
                string.concat(
                    "<defs><style>",
                    '@font-face {font-family: "EBGI";src: url("',
                    base64font,
                    '");',
                    // "text {text-transform: uppercase;"
                    "}</style>",
                    Effect.vhsFilter(
                        words.length <= 3 ? 4 : words.length <= 6
                            ? 3
                            : words.length <= 9
                            ? 2
                            : 1,
                        Traits.distortionType(entropy),
                        keccak256(
                            abi.encodePacked(Traits.textColor(words, entropy))
                        ) == keccak256(abi.encodePacked("#000000")),
                        animate
                    ),
                    "</defs>"
                ),
                Background.render(Traits.backgroundColor(words, entropy)),
                SVG.element(
                    "g",
                    string.concat(
                        SVG.filterAttribute("vhs"),
                        ' transform-origin="50% 50%" ',
                        'transform="rotate(',
                        Traits.textRotation(words, entropy),
                        ')"'
                    ),
                    _renderText(
                        words,
                        entropy,
                        Traits.textColor(words, entropy)
                    )
                )
            );
    }

    function _renderText(
        string[] memory words,
        bytes memory entropy,
        string memory textColor
    ) public pure returns (string memory) {
        uint256 wordCount = words.length;
        uint8 charsPerLine = 20;
        if (wordCount == 21) charsPerLine = 19;
        else if (wordCount == 18) charsPerLine = 18;
        else if (wordCount == 15) charsPerLine = 17;
        else if (wordCount == 12) charsPerLine = 16;
        else if (wordCount == 9) charsPerLine = 15;
        else if (wordCount == 6) charsPerLine = 12;
        else if (wordCount == 3) charsPerLine = 9;
        else if (wordCount != 24) revert("Invalid words per line");

        // the worst-case scenario is one word per line
        string[] memory tempLines = new string[](wordCount);
        string memory line;
        uint256 lineCount = 0;

        for (uint256 i = 0; i < words.length; i++) {
            if (
                bytes(line).length != 0 &&
                bytes(line).length + bytes(words[i]).length + 1 > charsPerLine
            ) {
                tempLines[lineCount] = line;
                lineCount++;
                line = words[i];
            } else {
                if (bytes(line).length != 0) {
                    line = string(abi.encodePacked(line, " ", words[i]));
                } else {
                    line = words[i];
                }
            }

            if (i == words.length - 1) {
                tempLines[lineCount] = line;
            }
        }

        string memory fontSize = "125";
        uint256 yDistance = 120;
        if (wordCount == 6) {
            fontSize = "93";
            yDistance = 93;
        } else if (wordCount == 9) {
            fontSize = "75";
            yDistance = 75;
        } else if (wordCount == 12) {
            fontSize = "75";
            yDistance = 75;
        } else if (wordCount == 15) {
            fontSize = "65";
            yDistance = 65;
        } else if (wordCount == 18) {
            fontSize = "62";
            yDistance = 62;
        } else if (wordCount == 21) {
            fontSize = "57";
            yDistance = 57;
        } else if (wordCount == 24) {
            fontSize = "55";
            yDistance = 55;
        }

        string memory svgTexts;
        for (uint256 i = 0; i <= lineCount; i++) {
            svgTexts = string.concat(
                svgTexts,
                TextLine.render(
                    tempLines[i],
                    90,
                    (444 - (lineCount * yDistance) / 2) + (i * yDistance),
                    fontSize,
                    textColor
                )
            );
        }

        return SVG.element("g", "", svgTexts);
    }
}
