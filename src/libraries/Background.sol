// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {SVG} from "./SVG.sol";
import {Util} from "./Util.sol";

library Background {
    /*//////////////////////////////////////////////////////////////
                                 RENDER
    //////////////////////////////////////////////////////////////*/

    function render(
        string memory backgroundColor
    ) internal pure returns (string memory) {
        return
            SVG.element(
                "rect",
                SVG.rectAttributes({
                    _width: "100%",
                    _height: "100%",
                    _fill: backgroundColor,
                    _attributes: ""
                })
            );
    }
}
