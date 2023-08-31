// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {SVG} from "./SVG.sol";
import {Util} from "./Util.sol";

library Effect {
    /*//////////////////////////////////////////////////////////////
                                 RENDER
    //////////////////////////////////////////////////////////////*/

    function vhsFilter(
        uint256 vhsLevel,
        uint256 distortionLevel,
        bool invert,
        bool animate
    ) internal pure returns (string memory) {
        string memory colorMatrix = invert
            ? "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.35 0"
            : "0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0.35 0";
        return
            string.concat(
                '<defs><filter id="vhs" x="0" y="0" width="616" height="889" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB"><feFlood flood-opacity="0" result="BackgroundImageFix" /><feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha" /><feOffset dx="',
                (
                    vhsLevel == 1 ? "-6" : vhsLevel == 2 ? "-9" : vhsLevel == 3
                        ? "-10"
                        : /*l4+*/ "-12"
                ),
                '" /><feGaussianBlur stdDeviation="2" /><feComposite in2="hardAlpha" operator="out" /><feColorMatrix type="matrix" values="',
                colorMatrix,
                '" /><feBlend mode="normal" in2="BackgroundImageFix" result="textBlur_pass1" /><feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha" /><feOffset dx="',
                vhsLevel == 1 ? "-3" : vhsLevel == 2 ? "-4.5" : vhsLevel == 3
                    ? "-5"
                    : /*l4+*/ "-6",
                '" /><feGaussianBlur stdDeviation="2" /><feComposite in2="hardAlpha" operator="out" /><feColorMatrix type="matrix" values="',
                colorMatrix,
                '" /><feBlend mode="normal" in2="textBlur_pass1" result="textBlur_pass2" /><feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha" /><feOffset dx="',
                vhsLevel == 1 ? "3" : vhsLevel == 2 ? "4.5" : vhsLevel == 3
                    ? "5"
                    : /*l4+*/ "6",
                '" /><feGaussianBlur stdDeviation="2" /><feComposite in2="hardAlpha" operator="out" /><feColorMatrix type="matrix" values="',
                colorMatrix,
                '" /><feBlend mode="normal" in2="textBlur_pass2" result="textBlur_pass3" /><feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha" /><feOffset dx="',
                vhsLevel == 1 ? "-6" : vhsLevel == 2 ? "-9" : vhsLevel == 3
                    ? "-10"
                    : /*l4+*/ "-12",
                '" /><feGaussianBlur stdDeviation="2" /><feComposite in2="hardAlpha" operator="out" /><feColorMatrix type="matrix" values="',
                colorMatrix,
                '" /><feBlend mode="normal" in2="textBlur_pass3" result="textBlur_pass4" /><feBlend mode="normal" in="SourceGraphic" in2="textBlur_pass4" result="shape" /><feGaussianBlur stdDeviation="',
                vhsLevel == 1 ? "3.5" : vhsLevel == 2 ? "4" : vhsLevel == 3
                    ? "4.5"
                    : /*l4+*/ "5",
                '" result="textBlur_pass5" />',
                '<feTurbulence baseFrequency=".015" type="fractalNoise" />',
                '<feColorMatrix type="hueRotate" values="0">',
                (
                    animate
                        ? '<animate attributeName="values" from="0" to="360" dur="16s" repeatCount="indefinite" />'
                        : ""
                ),
                "</feColorMatrix>",
                '<feDisplacementMap in="textBlur_pass5" xChannelSelector="R" yChannelSelector="B" scale="',
                distortionLevel == 1 ? "10" : distortionLevel == 2
                    ? "20"
                    : "22",
                '">',
                (
                    animate
                        ? (
                            string.concat(
                                '<animate attributeName="scale" values="',
                                distortionLevel == 1
                                    ? "10;20;15;25;15;20;10"
                                    : distortionLevel == 2
                                    ? "20;30;30;20"
                                    : "22:38:28:38:22",
                                '" dur="16s" repeatCount="indefinite" />'
                            )
                        )
                        : ""
                ),
                "</feDisplacementMap></filter></defs>"
            );
    }
}
