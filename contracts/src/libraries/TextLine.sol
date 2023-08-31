// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {Util} from "./Util.sol";
import {SVG} from "./SVG.sol";

library TextLine {
    /*//////////////////////////////////////////////////////////////
                                 RENDER
    //////////////////////////////////////////////////////////////*/

    function render(
        string memory text,
        uint256 xOffset,
        uint256 yOffset,
        string memory fontSize,
        string memory textColor
    ) internal pure returns (string memory) {
        return
            SVG.element(
                "text",
                SVG.textAttributes({
                    _fontSize: fontSize,
                    _fontFamily: "EBGI, EB Garamond Italic, Garamond Italic, EB Garamond, Garamond, serif",
                    _coords: [
                        Util.uint256ToString(xOffset),
                        Util.uint256ToString(yOffset)
                    ],
                    _fill: textColor,
                    _attributes: 'dy="0.4em"' // offset text so yCoord aligns with top of text (magic number)
                }),
                text
            );
    }
}
