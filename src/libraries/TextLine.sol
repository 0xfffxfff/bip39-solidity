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
        uint256 yOffset,
        string memory fontSize,
        string memory textColor
    ) internal pure returns (string memory) {
        return
            SVG.element(
                "text",
                SVG.textAttributes({
                    _fontSize: fontSize,
                    _fontFamily: "Bebas Neue, Impact, sans-serif",
                    _coords: ["67", Util.uint256ToString(yOffset)],
                    _fill: textColor,
                    _attributes: 'dy="0.4em"' // offset text so yCoord aligns with top of text (for Bebas Neue)
                }),
                text
            );
    }
}
