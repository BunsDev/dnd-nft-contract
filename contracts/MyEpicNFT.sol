// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    // OpenZeppelin methods to help keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Supply variables
    uint256 maxSupply = 50;
    uint256 totalNFTsMinted;

    // SVG code, split into three parts in order to randomize color and text
    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill:black; font-family: courier; font-size: 16px; font-weight: bold; letter-spacing: 1px; }</style><rect width='100%' height='100%' fill='";

    string svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "Human",
        "Duergar",
        "WoodElf",
        "Dragonborn",
        "StoutHalfling",
        "ForestGnome",
        "Drow",
        "DeepGnome",
        "LightfootHalfling",
        "RockGnome",
        "Tiefling",
        "HalfOrc",
        "HillDwarf",
        "HalfElf",
        "MountainDwarf",
        "HighElf"
    ];

    string[] secondWords = [
        "Rogue",
        "Druid",
        "Monk",
        "Bard",
        "Wizard",
        "Fighter",
        "Paladin",
        "Rogue",
        "Sorcerer",
        "Warlock",
        "Barbarian",
        "Ranger",
        "Cleric",
        "Artificer"
    ];

    string[] thirdWords = [
        "Charlatan",
        "Entertainer",
        "Sailor",
        "Artisan",
        "Hermit",
        "Noble",
        "FolkHero",
        "Outlander",
        "Sage",
        "Criminal",
        "Soldier",
        "Urchin",
        "Acolyte"
    ];

    string[] colors = [
        "Aquamarine",
        "BlanchedAlmond",
        "BlueViolet",
        "Chartreuse",
        "Coral",
        "DarkGrey",
        "DarkSlateGrey",
        "DarkOrange",
        "FireBrick",
        "HotPink",
        "LightSeaGreen",
        "Thistle",
        "Lavender",
        "Orange",
        "Salmon",
        "Yellow",
        "Turquoise",
        "MediumPurple"
    ];

    event MintedNewEpicNFT(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721("My D&D NFT", "DND") {
        console.log("My first NFT contract. HUZZAH!");
    }

    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // ensure rand is no longer than array length
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("RANDOM_COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    // helper function to determine randomness
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // NFT mint function
    function makeAnEpicNFT() public {
        require(
            totalNFTsMinted <= maxSupply,
            "The maximum supply has already been minted!"
        );

        // get current tokenId, this starts at 0
        // current is a methed from inherited contract
        uint256 newItemId = _tokenIds.current();

        // grab random word from each array
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );
        string memory color = pickRandomColor(newItemId);

        // concatenate random words with base svg and close tags
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                color,
                svgPartTwo,
                combinedWord,
                "</text></svg>"
            )
        );

        // get all JSON metadata and Base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A collection of Dungeons & Dragons characters based on randomly generated race, class, and background.",',
                        '"color": "',
                        color,
                        '", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        // inherited function
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        // in herited function
        _setTokenURI(newItemId, finalTokenUri);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        console.log(
            "An NFT with ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        totalNFTsMinted += 1;
        console.log(
            "A total of %d NFTs have been minted and %d remain. HUZZAH!",
            totalNFTsMinted,
            (maxSupply - totalNFTsMinted)
        );

        emit MintedNewEpicNFT(msg.sender, newItemId);
    }

    function getTotalNFTsMinted() public view returns (uint256) {
        return totalNFTsMinted;
    }
}
