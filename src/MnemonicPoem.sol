// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/src/tokens/ERC721.sol";
import "solmate/src/auth/Owned.sol";
import "./BIP39.sol";

contract MnemonicPoem is ERC721, BIP39, Owned {

    struct Mnemonic {
        uint256[] indices;
        bool bound;
    }
    mapping(uint256 => Mnemonic) public mnemonics;
    mapping(uint256 => bool) public mintedIndices;
    uint256 public wordPrice = 0.01 ether;
    uint256 public totalSupply;
    bool public locked = true;

    constructor() ERC721("Mnemonic Poem", "MNEMO") Owned(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                                  Mint
    //////////////////////////////////////////////////////////////*/

    function lock(bool state) external onlyOwner {
        locked = state;
    }

    function mint(uint256[] memory mnemonicIndices) external payable {
        require(!locked, "LOCKED");
        uint mnemonicPrice = wordPrice * mnemonicIndices.length;
        require(msg.value == mnemonicPrice, "PRICE");
        uint id = ++totalSupply;

        // This generates the entropy from the mnemonic indices
        // and serves us to validate the mnemonic.
        mnemonicToEntropy(mnemonicIndices);

        // Words can only be minted once.
        for (uint i = 0; i < mnemonicIndices.length; i++) {
            require(!mintedIndices[mnemonicIndices[i]], "WORD_ALREADY_MINTED");
            mintedIndices[mnemonicIndices[i]] = true;
        }

        // Store the mnemonic
        mnemonics[id].indices = mnemonicIndices;

        // Mint the token
        _mint(msg.sender, id);
    }

    /*//////////////////////////////////////////////////////////////
                                 RENDER
    //////////////////////////////////////////////////////////////*/

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
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

}