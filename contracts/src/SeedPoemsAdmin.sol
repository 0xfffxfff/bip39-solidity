// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/src/tokens/ERC721.sol";
import "solady/src/auth/Ownable.sol";
import "solady/src/utils/MerkleProofLib.sol";

error IncorrectPrice();
error MaxSupply();
error Paused();
error ReserveMintingDisabled();
error MaxClaimed();
error NoReserveForAddress();
error MaxReserveClaim();
error MaxPublicSupply();
error InvalidProof();

abstract contract SeedPoemsAdmin is ERC721, Ownable {

    uint256 public totalSupply;

    // Public Edition
    uint256 public constant MAX_WORD_SUPPLY = 2048;
    uint256 public constant ARTIST_ALLOTMENT = 245; // ~12%
    uint256 public constant WORD_SUPPLY = MAX_WORD_SUPPLY - ARTIST_ALLOTMENT;
    uint256 public constant RESERVE_ALLOTMENT = 717; // ~35%
    uint256 public constant PUBLIC_WORD_SUPPLY = WORD_SUPPLY - RESERVE_ALLOTMENT;
    uint256 public constant PRICE = 0.03 ether;
    uint256 public totalWords;
    uint256 public publicClaimed;
    uint256 public reserveClaimed;
    mapping (address => uint) reserve;
    mapping (address => uint) reserveMinted;
    bytes32 public reserveRoot;
    bool public mintReserveActive = true;
    bool public mintingPaused = true;

    // Curated Edition
    address public curatedMinter;
    modifier onlyCuratedMinter {
        require(msg.sender == curatedMinter, "NOT_CURATED_MINTER");
        _;
    }

    constructor () ERC721("Seed Poems", "SEED") {
        _initializeOwner(msg.sender);
        curatedMinter = msg.sender;
    }

    /*//////////////////////////////////////////////////////////////
                                  Mint
    //////////////////////////////////////////////////////////////*/

    modifier reserveMintChecks(bytes32[] calldata proof, uint256 max, uint256 words) {
        if (totalWords + words > MAX_WORD_SUPPLY) revert MaxSupply();
        if (mintingPaused) revert Paused();
        if (!mintReserveActive) revert ReserveMintingDisabled();
        if (reserveClaimed + words > RESERVE_ALLOTMENT) revert MaxClaimed();
        if (msg.value != PRICE) revert IncorrectPrice();

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, max))));
        bool validProof = MerkleProofLib.verifyCalldata(proof, reserveRoot, leaf);
        if (!validProof) revert InvalidProof();

        if (reserveMinted[msg.sender] + words > max) revert MaxReserveClaim();

        reserveMinted[msg.sender] += words;
        reserveClaimed += words;
        _;
    }

    modifier publicMintChecks(uint256 words) {
        if (totalWords + words > MAX_WORD_SUPPLY) revert MaxSupply();
        if (mintingPaused) revert Paused();
        if (mintReserveActive && publicClaimed + words > PUBLIC_WORD_SUPPLY) revert MaxPublicSupply();
        if (!mintReserveActive && publicClaimed + reserveClaimed + words > WORD_SUPPLY) revert MaxPublicSupply();
        if (msg.value != PRICE) revert IncorrectPrice();
        publicClaimed += words;
        _;
    }

    modifier ownerMintChecks(uint256 words) {
        if (totalWords + words > MAX_WORD_SUPPLY) revert MaxSupply();
        _;
    }

    /// @notice Pause/Unpause minting
    function setPause(bool value) public onlyOwner {
        mintingPaused = value;
    }

    /// @notice Disabling reserve minting will allow public minting of any remaining tokens
    function setReserve(bool value) public onlyOwner {
        mintReserveActive = value;
    }

    /// @notice Set merkle root for reserve claims
    function setReserveRoot(bytes32 newRoot) public onlyOwner {
        reserveRoot = newRoot;
    }

    /// @notice Withdraws balance to address
    function withdraw(address payable _to) public onlyOwner {
        (bool success,) = _to.call{value: address(this).balance}("");
        require(success);
    }

    /// @notice Transfer curated minter role
    function transferCuratedMinter(address newCuratedMinter) public onlyCuratedMinter {
        curatedMinter = newCuratedMinter;
    }

}
