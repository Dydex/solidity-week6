// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract DpNFT is ERC721, Ownable {
    uint256 public tokenCount;

     constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        mint(msg.sender);
    }

    function mint(address _to) public onlyOwner returns (bool) {
        uint256 tokenId = tokenCount + 1;
        _safeMint(_to, tokenId);
        tokenCount = tokenId;
        return true;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', name(), ' #', Strings.toString(_tokenId), '",',
                        '"description": "An NFT for the OnChain project",',
                        '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(SVGImage())), '"}'
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", uri));
    }


    function SVGImage() internal pure returns (string memory) {
    return string(
        abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">',
            '<circle cx="200" cy="200" r="180" fill="#003366" stroke="#000000" stroke-width="2" />',
            '<circle cx="200" cy="200" r="140" fill="#CC0000" stroke="#000000" stroke-width="2" />',
            '<circle cx="200" cy="200" r="100" fill="#FFFFFF" stroke="#000000" stroke-width="2" />',
            '<circle cx="200" cy="200" r="60" fill="#0066CC" stroke="#000000" stroke-width="2" />',
            '<path d="M200 155 L213 195 L255 195 L221 220 L234 260 L200 235 L166 260 L179 220 L145 195 L187 195 Z" fill="#FFFFFF" />',
            '</svg>'
        )
        );
    }
}