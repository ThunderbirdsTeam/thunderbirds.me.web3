// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// IBEP20 interface for BEP-20 standard
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ThunderbirdsTokenV2 is IBEP20 {
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;

    // Supply and balances
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    /**
     * @dev Constructor to initialize the token.
     * @param _name Token name (e.g., "Thunderbirds Token V2").
     * @param _symbol Token symbol (e.g., "TBIRDV2").
     * @param _decimals Number of decimal places (usually 18).
     * @param _initialSupply Initial total supply (without decimals; e.g., 150000000 with scale 10 for 1.5 billion tokens).
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _initialSupply * (10 ** _decimals);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Internal function to transfer tokens.
     * @param from Sender address.
     * @param to Recipient address.
     * @param value Amount to transfer.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(_balances[from] >= value, "Insufficient balance");

        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    /**
     * @dev Returns the total token supply.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the balance of an account.
     * @param account Address to query.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers tokens to a recipient.
     * @param to Recipient address.
     * @param value Amount to transfer.
     * @return success True if successful.
     */
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Returns the remaining allowance for a spender.
     * @param owner Token owner.
     * @param spender Spender address.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Approves a spender to transfer tokens on behalf of the caller.
     * @param spender Spender address.
     * @param value Amount to approve.
     * @return success True if successful.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfers tokens from one address to another using allowance.
     * @param from Sender address.
     * @param to Recipient address.
     * @param value Amount to transfer.
     * @return success True if successful.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(_allowances[from][msg.sender] >= value, "Insufficient allowance");
        _allowances[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Burns tokens from the caller's balance (burnable extension).
     * @param value Amount to burn.
     */
    function burn(uint256 value) external {
        require(_balances[msg.sender] >= value, "Insufficient balance");
        _balances[msg.sender] -= value;
        _totalSupply -= value;
        emit Transfer(msg.sender, address(0), value);
    }

    /**
     * @dev Returns the balance of an account.
     * @param account Address to burn from.
     * @param value Amount to burn.
     */
    function burnFrom(address account, uint256 value) external {
        require(_allowances[account][msg.sender] >= value, "Insufficient allowance");
        _allowances[account][msg.sender] -= value;
        require(_balances[account] >= value, "Insufficient balance");
        _balances[account] -= value;
        _totalSupply -= value;
        emit Transfer(account, address(0), value);
    }
}