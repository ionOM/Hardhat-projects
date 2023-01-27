// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract TheOwner {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    // Function that changes the owner.
    function transferOwnership(address _to) public {
        require(msg.sender == owner, "You are not the owner");
        newOwner = _to;
  }
    //To be completed the ownership transfer, this function must be called by newOwner.
    function acceptOwnership() public {
        require(msg.sender == newOwner, "You are not the newOwner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract MakeLoveToken is TheOwner {


    string private _name;
    string private _symbol;
    uint private _totalSupply;
    uint8 private _decimals;

    // Mapping of accounts and their balances.
    mapping(address => uint) private balances;

    // Mapping from addresses to allowances granted to other addresses.
    mapping(address=>mapping(address=>uint256)) private allowed;

    // Event emitted when the balance of an address changes.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Emitted when the allowance of a spender for an owner is set by a call to approve.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor () {
        _name = "Make Love Token";
        _symbol = "MLT";
        _totalSupply = 1000000000000000000000000;
        _decimals = 18;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // Name of the token.
    function name() public view returns (string memory) {
        return _name;
    }

    // Symbol of the token.
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // Number of decimals used to display token values.
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    // Total supply of tokens.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Get the balance of the specified address.
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // Allows a representative to transfer coins (which he does not own but has been granted the right to spend),
    // to another account.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Send the specified amount of tokens to the specified address.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        return transferFrom(msg.sender, _to, _value);
    }

    // Approve any address to spend the value on behalf of you.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Returns the token amount remaining, 
    // which the spender is currently allowed to withdraw from the owner's account.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Increase the total supply of the token. Only by the owner.
    function mint(address _to, uint amount) public {
        require(msg.sender == owner, "You are not the owner");
        balances[_to] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), _to, amount);
    }

    // Destroys `amount` tokens from the caller.
    function burn(uint amount) public {
        require(balances[msg.sender] >= amount, "Burn amount exceeds balance");
        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}