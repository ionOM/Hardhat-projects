// SPDX-License-Identifier: MIT

// address of the contract: 0xE0AE18E4Ac928ED41cEf1012BF0941aD9153B1B3

pragma solidity 0.8.17;

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns(bool);
    function balanceOf(address _account) external view returns(uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract Faucet {
    address payable owner;
    IERC20 public token;

    // The amount available for withdrawal.
    uint256 public withdrawalAmount = 50 * (10**18);

    // How long it has to wait for the next withdraw.
    uint256 public lockTime = 24 hours;

    // Event triggered when tokens are withdrawn.
    event withdrawal(address indexed _to, uint256 indexed _amount);

    // Event triggered when ether is deposited.
    event Deposit(address indexed _from, uint256 indexed _amount);

    // A mapping to store the next access time for each user.
    mapping(address => uint256) nextAccessTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner");
        _;
    }

    constructor(address _tokenAddress) payable {
        token = IERC20(_tokenAddress);
        owner = payable(msg.sender);
    }

    // Allows users to request tokens from the contract.
    function requestTokens() public {
        require(msg.sender != address(0), "Cannot claim from address 0");
        require(token.balanceOf(address(this)) >= withdrawalAmount, "Insufficient balance in faucet for withdrawal request");
        require(block.timestamp >= nextAccessTime[msg.sender], "Insufficient time elapsed since last withdrawal");

        nextAccessTime[msg.sender] = block.timestamp + lockTime;
        token.transfer(msg.sender, withdrawalAmount);
    }

    // Allows users to deposit funds to the contract.
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Returns the balance of the contract.
    function getBalance() external view returns(uint256) {
        return token.balanceOf(address(this));
    }

    // Allows the owner to set the withdrawal amount.
    function setwithdrawalAmount(uint256 _amount) public onlyOwner {
        withdrawalAmount = _amount * (10**18);
    }

    // Allows the owner to set the lockTime.
    function setLockTime(uint256 _amount) public onlyOwner {
        lockTime = _amount * 1 hours;
    }

    // Allows the owner to withdraw the balance of the contract.
    function withdraw() external onlyOwner {
        emit withdrawal(msg.sender, token.balanceOf(address(this)));
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}