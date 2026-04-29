// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract WEB3builder is ERC1155, Ownable, ERC1155Pausable, ERC1155Supply, PaymentSplitter{
    uint256 public publicprice = 0.05 ether;
    uint256 public allowListprice = 0.01 ether;
    uint256 public maxsupply = 5000;
    bool public publicMintopen = false;
    bool public allowListopen= true;
     mapping(address=> bool) allowList;
      mapping(address => uint256) purchasesPerWallet;
uint256 maxperwallet =3;
    constructor(address[] memory _payees, uint256[] memory _shares)
        ERC1155("ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/")
       PaymentSplitter(
            _payees,_shares
        )
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
     function uri(uint256 _id) public view virtual override returns (string memory) {
        require(exists(_id), "URI: nonexistent token");
        
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }
       function withdraw(address _addr) external onlyOwner {
        uint256 balance = address(this).balance; // get the balance of the smart contract
        payable(_addr).transfer(balance);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    function allowList(uint256 id, uint256 amount) public payable{
        require(allowListopen,"ALLOW LIST MINT IS CLOSED");
       require(msg.value == allowListprice * amount,"Insufficient funds");
        require(id < 2,"Invalid token ID");
        require(allowList[msg.sender],"YOU ARE NOT IN THE ALLOWLIST");
        mint( id, amount);

    }
    function setAllowlist( address[] calldata addresses) external onlyOwner{
        for(uint256 i=0; i< addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

    function publicmint( uint256 id, uint256 amount)
        public payable
        
    {
        require(publicMintopen, "PUBLIC MINT CLOSED");
        require(msg.value == publicprice * amount,"Insufficient funds");
        require(id < 2,"Invalid token ID");
        mint( id, amount);
    }
     function mint(uint256 id, uint256 amount) internal {
        require(purchasesPerWallet[msg.sender] + amount <= maxperwallet, "Wallet limit reached");
        require(id < 2, "Sorry looks like you are trying to mint the wrong NFT");
        require(totalSupply(id) + amount  <= maxsupply, "Sorry we have minted out!");
        _mint(msg.sender, id, amount, "");
        purchasesPerWallet[msg.sender] += amount;
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.
       function editMintWindows(
        bool _publicMintopen,
        bool _allowListopen
       ) external onlyOwner {
        publicMintopen = _publicMintopen;
        allowListopen = _allowListopen;
       }
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}