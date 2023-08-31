// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solady/src/utils/SSTORE2.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./BIP39.sol";
import "./SeedPoemsAdmin.sol";
import {Render} from "./libraries/Render.sol";

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                               seek                                 //
//                               poet                                 //
//                               seed                                 //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                                    //
//                                                       0xfff.eth    //
//                                                                    //
////////////////////////////////////////////////////////////////////////

contract SeedPoems is BIP39, SeedPoemsAdmin, ReentrancyGuard {
    struct Seed {
        uint256[] indices;
        bytes entropy;
        bool bound;
    }

    mapping(uint256 => Seed) public seeds;
    mapping(bytes32 => bool) public isEntropyMinted;

    address private font;

    constructor() SeedPoemsAdmin() {
        uint256[] memory seedIndices = new uint256[](3);
        seedIndices[0] = 1560; // seek
        seedIndices[1] = 1337; // poet
        seedIndices[2] = 1559; // seed
        _mintPoem(seedIndices, msg.sender, false);
    }

    /*//////////////////////////////////////////////////////////////
                                 MINT
    //////////////////////////////////////////////////////////////*/

    function mint(
        uint256[] memory seedIndices
    )
        external
        payable
        nonReentrant
        publicMintChecks(seedIndices.length)
    {
        _mintPoem(seedIndices, msg.sender, false);
    }

    function mintArtist(
        uint256[] memory seedIndices,
        address to,
        bool bound
    )
        external
        payable
        onlyOwner
        ownerMintChecks(seedIndices.length)
        nonReentrant
    {
        _mintPoem(seedIndices, to, bound);
    }

    function _mintPoem(
        uint256[] memory seedIndices,
        address to,
        bool bound
    ) internal {
        uint id = ++totalSupply;

        // Keep track of words minted
        totalWords += seedIndices.length;
        require(
            totalWords <= MAX_WORD_SUPPLY,
            "MINTABLE_WORD_LIMIT_REACHED_2048"
        );

        // This generates the entropy from the seed indices
        // and simultaneously validates the seed.
        bytes memory entropy = mnemonicToEntropy(seedIndices);

        // hash entropy to check if it has been minted
        bytes32 entropyHash = keccak256(entropy);
        require(!isEntropyMinted[entropyHash], "MNEMONIC_ALREADY_MINTED");
        isEntropyMinted[entropyHash] = true;

        // Store the seed
        seeds[id] = Seed({
            indices: seedIndices,
            entropy: entropy,
            bound: bound
        });

        // Mint the token
        _mint(to, id);
    }

    /*//////////////////////////////////////////////////////////////
                                 BINDING
    //////////////////////////////////////////////////////////////*/

    /**
     * This method allows a seed poem to be bound to a specific
     * address that is derived from the seed itself.
     * @param id tokenId of the poem to be bound
     */
    function bind(
        uint256 id,
        address to /*, message, signature, address */
    ) public {
        require(ownerOf(id) == msg.sender, "ONLY_OWNER");
        transferFrom(msg.sender, to, id);
        seeds[id].bound = true;
        // TODO: require valid signature signed offchain by the artist's "validator"
        revert('IMPLEMENT_ME');
    }

    // Inherit natspec
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(!seeds[id].bound, "BOUND");
        super.transferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(!seeds[id].bound, "BOUND");
        super.safeTransferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public override {
        require(!seeds[id].bound, "BOUND");
        super.safeTransferFrom(from, to, id, data);
    }

    /*//////////////////////////////////////////////////////////////
                                 VIEW
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Intended to be used offchain
     */
    function getMintedIndices() external view returns (uint256[] memory) {
        uint256[] memory mintedIndicesArray = new uint256[](totalWords);
        uint words = 0;
        for (uint i = 0; i < totalSupply; i++) {
            for (uint j = 0; j < seeds[i].indices.length; j++) {
                mintedIndicesArray[words++] = seeds[i].indices[j];
            }
        }
        return mintedIndicesArray;
    }

    /*//////////////////////////////////////////////////////////////
                                 RENDER
    //////////////////////////////////////////////////////////////*/

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_ownerOf[_tokenId] != address(0), "NOT_MINTED");
        return
            Render.tokenURI(
                _tokenId,
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                getFont()
            );
    }

    function renderSVG(uint256 _tokenId) external view returns (string memory) {
        return
            Render.renderSVG(
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                getFont()
            );
    }

    function renderSVGFromWords(
        uint256[] memory seedIndices
    ) external view returns (string memory) {
        bytes memory entropy = mnemonicToEntropy(seedIndices);
        return
            Render.renderSVG(indicesToWords(seedIndices), entropy, getFont());
    }

    function renderSVGBase64(
        uint256 _tokenId
    ) external view returns (string memory) {
        return
            Render.renderSVGBase64(
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                getFont()
            );
    }

    function renderSVGBase64FromWords(
        uint256[] memory seedIndices
    ) external view returns (string memory) {
        bytes memory entropy = mnemonicToEntropy(seedIndices);
        return
            Render.renderSVGBase64(
                indicesToWords(seedIndices),
                entropy,
                getFont()
            );
    }

    function renderSVGstatic(
        uint256 _tokenId
    ) external view returns (string memory) {
        return
            Render.renderSVGstatic(
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                getFont()
            );
    }

    function renderSVGstaticFromWords(
        uint256[] memory seedIndices
    ) external view returns (string memory) {
        bytes memory entropy = mnemonicToEntropy(seedIndices);
        return
            Render.renderSVGstatic(
                indicesToWords(seedIndices),
                entropy,
                getFont()
            );
    }

    function renderSVGBase64static(
        uint256 _tokenId
    ) external view returns (string memory) {
        return
            Render.renderSVGBase64static(
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                getFont()
            );
    }

    function renderSVGBase64staticFromWords(
        uint256[] memory seedIndices
    ) external view returns (string memory) {
        bytes memory entropy = mnemonicToEntropy(seedIndices);
        return
            Render.renderSVGBase64static(
                indicesToWords(seedIndices),
                entropy,
                getFont()
            );
    }

    ///////////////////////////////////////////////////////////////////////////
    // Font
    ///////////////////////////////////////////////////////////////////////////

    function setFont(
        string calldata fontString
    )
        external
        onlyOwner
    {
        font = SSTORE2.write(bytes(fontString));
    }

    function getFont() public view returns (string memory) {
        return string(abi.encodePacked(SSTORE2.read(font)));
    }
}
