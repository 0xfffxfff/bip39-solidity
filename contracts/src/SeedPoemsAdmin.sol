// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "solmate/src/tokens/ERC721.sol";
import "solady/src/auth/Ownable.sol";

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

    uint256 public constant MAX_WORD_SUPPLY = 2048;
    uint256 public constant ARTIST_ALLOTMENT = 408; // 20% of words
    uint256 public constant WORD_SUPPLY = MAX_WORD_SUPPLY - ARTIST_ALLOTMENT;
    uint256 public constant PRICE = 0.03 ether;

    uint256 public totalSupply;

    uint256 public totalWords;
    uint256 public publicClaimed;
    mapping (address => uint) reserve;

    bytes32 public reserveRoot;

    bool public mintReserveActive = true;
    bool public mintingPaused = true;

    constructor () ERC721("Seed Poems", "SEED") {
        _initializeOwner(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                                  Mint
    //////////////////////////////////////////////////////////////*/

    modifier publicMintChecks(uint256 words) {
        if (totalWords + words > MAX_WORD_SUPPLY) revert MaxSupply();
        if (mintingPaused) revert Paused();
        if (publicClaimed + words > WORD_SUPPLY) revert MaxPublicSupply();
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

    /// @notice Withdraws balance to address
    function withdraw(address payable _to) public onlyOwner {
        (bool success,) = _to.call{value: address(this).balance}("");
        require(success);
    }

}
