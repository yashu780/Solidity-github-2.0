// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721Pausable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

contract Web3erc721 is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256  public maxsupply = 5000;
    bool public publicMintopen = false;
    bool public allowlistmintopen = false;
    mapping(address => bool) public Allowlistmint;

    constructor()
    ERC721("web3erc721", "we3")
    Ownable(msg.sender)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editmintwindow(bool _publicMintopen,bool _allowlistmintopen) external onlyOwner{
        publicMintopen =_publicMintopen;
        allowlistmintopen =_allowlistmintopen;
    }

    function allowlistmint() public payable{
        require(allowlistmintopen,"ALLOW LIST MINT CLOSED");
        require(Allowlistmint[msg.sender],"YOU ARE NOT IN ALLOW LIST ");
        require(msg.value == 0.1 ether,"NOT ENOUGH FUNDS");
        internalmint();
    }

    function publicMint() public payable returns(uint256){
        require(publicMintopen,"PUBLICLIST MINT CLOSED");
        require(msg.value == 0.01 ether, "NOT ENOUGH FUNDS");
        return internalmint();
    }

    function internalmint() internal returns(uint256){
        require(totalSupply()< maxsupply,"WE SOLD OUT");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        return tokenId;
    }
    function withdraw(address _addr) external onlyOwner{
        uint256 balanlce = address(this).balance;
        payable(_addr).transfer(balanlce);
    } 

    // The following functions are overrides required by Solidity.
    function setAllowlist(address[] calldata addresses)external onlyOwner{
       for(uint256 i=0; i< addresses.length; i++){
        Allowlistmint[addresses[i]] = true;
       } 
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}