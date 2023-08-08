// SPDX-License-Identifier: MIT
// BearNetworkChain by 2023/08/08
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WBRNKC is Ownable {
    using SafeMath for uint256;

    string public name = "Wrapped BRNKC";
    string public symbol = "WBRNKC";
    uint8 public decimals = 18;
    uint256 public exchangeRate = 1;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public blacklist;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
    event BlacklistAdded(address indexed addr);
    event BlacklistRemoved(address indexed addr);
    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
    event FundsReceived(address indexed account, uint256 amount);
    event FundsSent(address indexed account, uint256 amount);
    event WBRNKCConvertedToBRNKC(address indexed account, uint256 amount);

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value);
        emit Deposit(msg.sender, msg.value);
        emit FundsReceived(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) public {
        require(balanceOf[msg.sender] >= wad, "Insufficient balance");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(wad);
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
        emit FundsSent(msg.sender, wad);
    }

    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    function _approve(address owner, address guy, uint256 amount) internal {
        require(owner != address(0), "Invalid owner address");
        require(guy != address(0), "Invalid spender address");
        allowance[owner][guy] = amount;
    }

    function approve(address guy, uint256 amount) public returns (bool) {
        _approve(msg.sender, guy, amount);
        emit Approval(msg.sender, guy, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Invalid sender address");
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf[sender] >= amount, "Insufficient balance");
        balanceOf[sender] = balanceOf[sender].sub(amount);
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(!blacklist[msg.sender], "Sender address is in the blacklist");
        require(!blacklist[recipient], "Recipient address is in the blacklist");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(!blacklist[sender], "Source address is in the blacklist");
        require(!blacklist[recipient], "Destination address is in the blacklist");
        require(amount <= allowance[sender][msg.sender], "Allowance not enough");
        _transfer(sender, recipient, amount);
        allowance[sender][msg.sender] = allowance[sender][msg.sender].sub(amount);
        return true;
    }

    function addToBlacklist(address addr) public onlyOwner {
        blacklist[addr] = true;
        emit BlacklistAdded(addr);
        emit Blacklisted(addr);
    }

    function removeFromBlacklist(address addr) public onlyOwner {
        blacklist[addr] = false;
        emit BlacklistRemoved(addr);
        emit Unblacklisted(addr);
    }
    
    function swapWBRNKCForBRNKC(uint256 amount) public {
        require(!blacklist[msg.sender], "Sender address is in the blacklist");
        require(balanceOf[msg.sender] >= amount, "Insufficient WBRNKC balance");

        uint256 brnkcAmount = amount.mul(exchangeRate);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        payable(msg.sender).transfer(brnkcAmount);

        emit Transfer(address(this), msg.sender, brnkcAmount);
        emit FundsSent(msg.sender, brnkcAmount);
        emit WBRNKCConvertedToBRNKC(msg.sender, brnkcAmount);
    }
}
