// PSDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

//Import some OpenZeppeling Contracts for NFTs
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol"; 
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "artifacts/contracts/libraries/Base64.sol";

//MyEpicNFT inherits from the imported Smart Contract 'ERC721URISTORAGE
//Heritance will allow us to use the inherite contract methods
contract MyEpicNFT is ERC721URIStorage{

    //Track of tokenIds provided by OpenZeppelin
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; //Definition of field ID (unique for each NFT)

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever! 
    //RECOMENDATION: 15-20 WORDS PER ARRAY TO BE RANDOM
    string[] firstWords = ["Bitcoin", "Ethereum", "Chainlink", "Solana", "Cardano", "Doge"];
    string[] secondWords = ["Frontend_dev", "Backend_dev", "Fullstack_dev", "Core_dev", "Architec", "Deginer"];
    string[] thirdWords = ["Java", "Python", "Solidity", "C", "Go", "JavaScript"];

    //Need to pass name of our NFTs token and it's symbol
    constructor() ERC721("SquareNFT", "SQUARE"){
        console.log("NFT contract is here!");
    }

    // I create a function to randomly pick a word from each array.
    //Its not truly random. To get perfect randomness use Chainlink RVF
   function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
    }

  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

    //Function the user will hit to get their NFT
    function makeAnEpicNFT() public{

        //Get the current tokenId (starts at 0)
        uint256 newItemId = _tokenIds.current();

         // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

         // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

         // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                 abi.encodePacked(
                     '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "NFTs randomly generated from my first coded collection!", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        //Mint the NFT to the sender using msg.sender
        _safeMint(msg.sender, newItemId); //msg.sender is the address of the person that is calling the contract (minting the NFT)

        //Set NFT Data
        //Second field URI with JSON metadata of our NFT -> base64 encoded json -> "data:application/json;base64,INSERT_BASE_64_ENCODED_JSON_HERE"
        //_setTokenURI(newItemId, "data:application/json;base64,ewoibmFtZSI6IkVwaWNMb3JkSGFtYnVyZ3VlciIsCiJkZXNjcmlwdGlvbiI6IlVuaXF1ZSBORlQgZnJvbSBteSBmaXJzdCBjb2RpbmcgY29sbGVjdGlvbiEiLAoiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0S0lDQWdJRHh6ZEhsc1pUNHVZbUZ6WlNCN0lHWnBiR3c2SUhkb2FYUmxPeUJtYjI1MExXWmhiV2xzZVRvZ2MyVnlhV1k3SUdadmJuUXRjMmw2WlRvZ01UUndlRHNnZlR3dmMzUjViR1UrQ2lBZ0lDQThjbVZqZENCM2FXUjBhRDBpTVRBd0pTSWdhR1ZwWjJoMFBTSXhNREFsSWlCbWFXeHNQU0ppYkdGamF5SWdMejRLSUNBZ0lEeDBaWGgwSUhnOUlqVXdKU0lnZVQwaU5UQWxJaUJqYkdGemN6MGlZbUZ6WlNJZ1pHOXRhVzVoYm5RdFltRnpaV3hwYm1VOUltMXBaR1JzWlNJZ2RHVjRkQzFoYm1Ob2IzSTlJbTFwWkdSc1pTSStSWEJwWTB4dmNtUklZVzFpZFhKblpYSThMM1JsZUhRK0Nqd3ZjM1puUGc9PSIKfQ==");
        
         // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        //Increment ID counter for next NFT to be minted
        //There wont be two minted NFT with the same Id
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
    }



}