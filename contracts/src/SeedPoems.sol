// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solady/src/utils/SSTORE2.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./BIP39.sol";
import "./SeedPoemsAdmin.sol";
import "./misc/Editions.sol";
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
        Edition edition;
    }

    mapping(uint256 => Seed) public seeds;
    mapping(uint256 => bool) public isWordMinted;
    mapping(bytes32 => bool) public isEntropyMinted;

    address private font;

    constructor() SeedPoemsAdmin() {
        uint256[] memory seedIndices = new uint256[](3);
        seedIndices[0] = 1560; // seek
        seedIndices[1] = 1337; // poet
        seedIndices[2] = 1559; // seed
        _mintPoem(seedIndices, msg.sender, Edition.Public, false);
    }

    /*//////////////////////////////////////////////////////////////
                                 MINT
    //////////////////////////////////////////////////////////////*/

    function _mintPoemPublic(
        uint256[] memory seedIndices,
        address to,
        bool bound
    ) internal {
        // Keep track of words minted
        totalWords += seedIndices.length;
        require(
            totalWords <= MAX_WORD_SUPPLY,
            "MINTABLE_WORD_LIMIT_REACHED_2048"
        );

        // Words in the limited edition can only be minted once
        for (uint i = 0; i < seedIndices.length; i++) {
            require(!isWordMinted[seedIndices[i]], "WORD_ALREADY_MINTED");
            isWordMinted[seedIndices[i]] = true;
        }

        _mintPoem(seedIndices, to, Edition.Public, bound);
    }

    function _mintPoem(
        uint256[] memory seedIndices,
        address to,
        Edition edition,
        bool bound
    ) internal {
        uint id = ++totalSupply;

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
            edition: edition,
            bound: bound
        });

        // Mint the token
        _mint(to, id);
    }

    function mint(
        uint256[] memory seedIndices
    ) external payable nonReentrant publicMintChecks(seedIndices.length) {
        _mintPoem(seedIndices, msg.sender, Edition.Public, false);
    }

    function mintReserve(
        uint256[] memory seedIndices,
        bytes32[] calldata proof,
        uint256 max
    )
        external
        payable
        reserveMintChecks(proof, max, seedIndices.length)
        nonReentrant
    {
        _mintPoem(seedIndices, msg.sender, Edition.Public, false);
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
        _mintPoem(seedIndices, to, Edition.Public, bound);
    }

    function mintCurated(
        uint256[] memory seedIndices,
        address to,
        bool bound
    ) external payable onlyCuratedMinter nonReentrant {
        _mintPoem(seedIndices, to, Edition.Curated, bound);
    }

    /*//////////////////////////////////////////////////////////////
                                 BINDING
    //////////////////////////////////////////////////////////////*/

    /**
     * This method allows a seed poem to be bound to a specific
     * address. This is meant to be an option for the owner of
     * the seed poem to bind it to a derived address of the seed.
     * It is not enforcable onchain, but it is verifiable offchain.
     * @param id tokenId of the poem to be bound
     */
    function bind(uint256 id, address to) public {
        require(ownerOf(id) == msg.sender, "ONLY_OWNER");
        transferFrom(msg.sender, to, id);
        seeds[id].bound = true;
        revert("IMPLEMENT_ME");
    }

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
                seeds[_tokenId].bound,
                seeds[_tokenId].edition,
                getFont()
            );
    }

    function renderSVG(uint256 _tokenId) external view returns (string memory) {
        return
            Render.renderSVG(
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                seeds[_tokenId].bound,
                seeds[_tokenId].edition,
                getFont()
            );
    }

    function renderSVGFromWords(
        uint256[] memory seedIndices
    ) external view returns (string memory) {
        bytes memory entropy = mnemonicToEntropy(seedIndices);
        return
            Render.renderSVG(
                indicesToWords(seedIndices),
                entropy,
                false,
                Edition.Public,
                getFont()
            );
    }

    function renderSVGBase64(
        uint256 _tokenId
    ) external view returns (string memory) {
        return
            Render.renderSVGBase64(
                indicesToWords(seeds[_tokenId].indices),
                seeds[_tokenId].entropy,
                seeds[_tokenId].bound,
                seeds[_tokenId].edition,
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
                false,
                Edition.Public,
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
                seeds[_tokenId].bound,
                seeds[_tokenId].edition,
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
                false,
                Edition.Public,
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
                seeds[_tokenId].bound,
                seeds[_tokenId].edition,
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
                false,
                Edition.Public,
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
