// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/src/tokens/ERC721.sol";
import "solmate/src/auth/Owned.sol";
import "solady/src/utils/SSTORE2.sol";
import "./BIP39.sol";
import {Render} from "./libraries/Render.sol";

contract MnemonicPoem is ERC721, BIP39, Owned {
    struct Mnemonic {
        uint256[] indices;
        bytes entropy;
        bool bound;
    }
    mapping(uint256 => Mnemonic) public mnemonics;

    uint256 public totalSupply;
    uint256 public wordPrice = 0.01 ether;

    bool public locked = true; // prevent minting

    mapping(uint256 => bool) public isIndexMinted;
    uint256 totalWords = 0; // total minted words

    address private font;

    constructor() ERC721("Mnemonic Poem", "MNEMO") Owned(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                                  Mint
    //////////////////////////////////////////////////////////////*/

    function lock(bool state) external onlyOwner {
        locked = state;
    }

    function mint(uint256[] memory mnemonicIndices) external payable {
        uint mnemonicPrice = wordPrice * mnemonicIndices.length;
        require(!locked, "LOCKED");
        require(msg.value == mnemonicPrice, "PRICE");
        uint id = ++totalSupply;

        // This generates the entropy from the mnemonic indices
        // and simultaneously validates the mnemonic.
        bytes memory entropy = mnemonicToEntropy(mnemonicIndices);

        // Words can only be minted once
        for (uint i = 0; i < mnemonicIndices.length; i++) {
            require(!isIndexMinted[mnemonicIndices[i]], "WORD_ALREADY_MINTED");
            isIndexMinted[mnemonicIndices[i]] = true;
        }

        // Keep track of words minted
        totalWords += mnemonicIndices.length;

        // Store the mnemonic
        mnemonics[id] = Mnemonic({
            indices: mnemonicIndices,
            entropy: entropy,
            bound: false
        });

        // Mint the token
        _mint(msg.sender, id);
    }

    /**
     * Intended to be used offchain
     */
    function getMintedIndices() external view returns (uint256[] memory) {
        uint256[] memory mintedIndicesArray = new uint256[](totalWords);
        uint words = 0;
        for (uint i = 0; i < totalSupply; i++) {
            for (uint j = 0; j < mnemonics[i].indices.length; j++) {
                mintedIndicesArray[words++] = mnemonics[i].indices[j];
            }
        }
        return mintedIndicesArray;
    }

    /*//////////////////////////////////////////////////////////////
                                 BINDING
    //////////////////////////////////////////////////////////////*/

    /**
     * This method allows a mnemonic poem to be bound to a specific
     * address that is derived from the mnemonic itself.
     * @param id tokenId of the poem to be bound
     */
    function bind(uint256 id /* to, message, signature, address */) public {
        require(ownerOf(id) == msg.sender, "ONLY_OWNER");
        // TODO: require valid signature signed offchain by the artist's "validator"
        mnemonics[id].bound = true;
    }

    // Inherit natspec
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(!mnemonics[id].bound, "BOUND");
        super.transferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(!mnemonics[id].bound, "BOUND");
        super.safeTransferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public override {
        require(!mnemonics[id].bound, "BOUND");
        super.safeTransferFrom(from, to, id, data);
    }

    /*//////////////////////////////////////////////////////////////
                                 RENDER
    //////////////////////////////////////////////////////////////*/

    function renderSVG(uint256 _tokenId) external view returns (string memory) {
        Mnemonic memory mnemonic = mnemonics[_tokenId];
        return
            Render.renderSVG(
                _tokenId,
                indicesToWords(mnemonic.indices),
                mnemonic.entropy,
                getFont()
            );
    }

    function renderSVGBase64(
        uint256 _tokenId
    ) external view returns (string memory) {
        Mnemonic memory mnemonic = mnemonics[_tokenId];
        return
            Render.renderSVGBase64(
                _tokenId,
                indicesToWords(mnemonic.indices),
                mnemonic.entropy,
                getFont()
            );
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_ownerOf[_tokenId] != address(0), "NOT_MINTED");
        Mnemonic memory mnemonic = mnemonics[_tokenId];
        return
            Render.tokenURI(
                _tokenId,
                indicesToWords(mnemonic.indices),
                mnemonic.entropy,
                getFont()
            );
    }

    ///////////////////////////////////////////////////////////////////////////
    // Font
    ///////////////////////////////////////////////////////////////////////////

    function setFont(string calldata fontString) external onlyOwner {
        font = SSTORE2.write(bytes(fontString));
    }

    function getFont() public view returns (string memory) {
        return string(abi.encodePacked(SSTORE2.read(font)));
    }
}
