//SPDX-License-Identifier : MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";

contract owned {
    address public owner;
    mapping(address => bool) admins;
    mapping(address => bool) developers;
    mapping(address => bool) players;
    constructor () {
        owner = msg.sender;
        admins[msg.sender] = true;
        developers[msg.sender] = true;
    }
    //modifiers for the contracts
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyAdmin() {
        require(admins[msg.sender] == true);
            _;
    }
    modifier onlyDevelopers(){
        require(developers[msg.sender]==true);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    function isAdmin(address account) onlyOwner public view returns (bool) {   
        return admins[account];
    }
    function isDeveloper(address account) onlyOwner public view returns (bool) {   
        return developers[account];
    }
    function addAdmin(address account) onlyOwner public {
        require(account != address(0) && !admins[account]);             
        admins[account] = true;    
    }
    function addGameDeveloper(address account) onlyAdmin public {
        require(account != address(0) && !developers[account]);             
        developers[account] = true;    
    }
    function addPlayer(address account) onlyAdmin public {
        require(account != address(0) && !players[account]);             
        players[account] = true;    
    }
}
contract AllowList is owned {
    mapping(address => bool) allowList;
    //Allowlist functions for security
    function addAllowList(address account) onlyAdmin public{
        require(account != address(0) && !allowList[account]);             
        allowList[account] = true;    
    }

    function isAllowList(address account) public view returns (bool) {   
        return allowList[account];
    }

    function removeAllowListed(address account) public onlyAdmin {
        require(account != address(0) && allowList[account]);
        allowList[account] = false;    
    }
}
/**
 * make contract function pausable
 */
contract Pausable is owned {
    event PausedEvt(address account);
    event UnpausedEvt(address account);
    bool private paused;
    constructor  () {
        paused = false;
    }
    //Pause mechanism for security
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    function pause() public onlyAdmin whenNotPaused {
        paused = true;
        emit PausedEvt(msg.sender);
    }
    function unpause() public onlyAdmin whenPaused {
        paused = false;
        emit UnpausedEvt(msg.sender);
    }
}
interface Inventory {
    enum Damage {zero,one,two,three,four,fivve,six}
    struct Item {
        uint id;
        string name;
        Damage damage;
        uint price;
        address owner;
        bool purchased;
    }
    function addItem(uint _id, string memory _name, Damage _damage, uint _price) external;
    function buyItem(uint _id) external payable;
}

interface IERC20{
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract GameToken is IERC20,AllowList,Pausable,Inventory {
    string public name = "KriDe";
    string public symbol = "KD";
    address payable contractAccount;
    TokenSummary public tokensummary;
    struct TokenSummary {
        address initialAccount;
        string name;
        string symbol;
    }
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    mapping(uint => Item) public items;
    uint public itemCount;
    mapping(address => uint) internal rewards;
    uint256 internal _totalSupply;
    uint8 public tokenAmount = 15;
    uint8 public tokenReward;
    uint8 public constant SUCCESS_CODE = 0;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    uint8 public constant DENY_LIST_CODE = 1;
    string public constant DENY_LIST_ERROR = "ILLEGAL_TRANSFER_TO_DENY_LISTED_ADDRESS";
    event Burn(address from, uint256 value);
    constructor(address initialAccount, uint initialBalance) public payable {
        addAllowList(initialAccount);
        balances[initialAccount] = initialBalance;
        _totalSupply = initialBalance;
        tokensummary = TokenSummary(initialAccount, name, symbol);
    }
    modifier verify (address from, address to, uint256 value) {
        uint8 restrictionCode = validateTransferRestricted(to);
        require(restrictionCode == SUCCESS_CODE, messageHandler(restrictionCode));
        _;
    }

    function validateTransferRestricted (address to) public view returns (uint8 restrictionCode) {
        if (!isAllowList(to)) {
            restrictionCode = DENY_LIST_CODE;
        } else {
            restrictionCode = SUCCESS_CODE;
        }
    }
    function messageHandler (uint8 restrictionCode) public pure returns (string memory message) {
        if (restrictionCode == SUCCESS_CODE) {
            message = SUCCESS_MESSAGE;
        } else if(restrictionCode == DENY_LIST_CODE) {
            message = DENY_LIST_ERROR;
        }
    }
    //return total supply
    function totalSupply() public view returns (uint256) {
       return _totalSupply;
    }
    // return the token balance of an account
    function balanceOf(address account) public view returns (uint256) {
      return balances[account];
    }
    // to transfer tokens between addresses in the allowlist
    function transfer(address to, uint256 value) public verify(msg.sender, to, value)
    whenNotPaused  returns (bool success) {
        require(to != address(0) && balances[msg.sender]> value);
        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    // to transfer tokens when allowance is set
    function transferFrom(address from, address spender,uint256 value) public verify(from, spender, value) whenNotPaused returns (bool) {
        require(spender != address(0) && value <= balances[from] && value <= allowed[from][msg.sender]);
        balances[from] = balances[from] - value;
        balances[spender] = balances[spender] + value;
        allowed[from][msg.sender] = allowed[from][msg.sender] - value;
        emit Transfer(from, spender, value);
        return true;
  	}
    // to retrieve the remaining allowance set between two addresses
	function allowance(address owner,address spender) public view returns (uint256) {
   		return allowed[owner][spender];
 	}
    // to approve an allowance to an address
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
   	}
    // to add an item to the inventory list
    function addItem(uint _id, string memory _name, Damage _damage, uint _price) external onlyDevelopers override {
        items[itemCount] = Item(_id, _name, _damage, _price, msg.sender, false);
        itemCount++;
    }
    // to buy an item in the inventory list
    function buyItem(uint _id) external payable override {
        require(items[_id].id != 0, "Item does not exist");
        require(items[_id].purchased == false, "Item is already purchased");
        require(balances[msg.sender] >= items[_id].price, "Insufficient funds");
        //Transfer funds
        address seller = items[_id].owner;
        uint amount = items[_id].price;
        transfer(payable(seller),amount);
        items[_id].owner = msg.sender;
        items[_id].purchased = true;
    }
    // to retrieve items owned by an address
    function getItemsByOwner(address _owner) external view returns (Item[] memory) {
        uint ownedItemCount = 0;
        for (uint i = 0; i < itemCount; i++) {
            if (items[i].owner == _owner) {
                ownedItemCount++;
            }
        }
        Item[] memory ownedItems = new Item[](ownedItemCount);
        uint ownedItemIndex = 0;
        for (uint i = 0; i < itemCount; i++) {
            if (items[i].owner == _owner) {
                ownedItems[ownedItemIndex] = items[i];
                ownedItemIndex++;
            }
        }
        return ownedItems;
    }
    // to retrieve all the unpurchased items in the inventory list
    function getUnpurchasedItems() external view returns (Item[] memory) {
            uint unpurchasedItemCount = 0;
            for (uint i = 0; i < itemCount; i++) {
                if (items[i].purchased == false) {
                    unpurchasedItemCount++;
                }
            }
            Item[] memory unpurchasedItems = new Item[](unpurchasedItemCount);
            uint unpurchasedItemIndex = 0;
            for (uint i = 0; i < itemCount; i++) {
                if (items[i].purchased == false) {
                    unpurchasedItems[unpurchasedItemIndex] = items[i];
                    unpurchasedItemIndex++;
                }
            }
            return unpurchasedItems;
    }
    
    //To transfer tokens as rewards
    function addTokenByGamesWon(address player, uint8 gamesWon) public whenNotPaused onlyAdmin {
        require(allowList[player] == true, "Player is not in the allowlist.");
        tokenReward = gamesWon * tokenAmount;
        balances[player] = safeArithmetic.add(balances[player],tokenReward);
        balances[tokensummary.initialAccount] = balances[tokensummary.initialAccount] - tokenReward;
        rewards[player]=safeArithmetic.add(rewards[player],tokenReward);
    }
    // to retrieve rewards earned tokens of an address
    function getReward(address _player) public view returns (uint) {
        return rewards[_player];
    }

    function burn(uint256 value) public whenNotPaused onlyAdmin returns (bool success) {
		require(balances[msg.sender] >= value); 
		balances[msg.sender] -= value; 
		_totalSupply -= value;
		emit Burn(msg.sender, value);
		return true;
	}
	
	function mint(address account, uint256 value) public whenNotPaused onlyAdmin returns (bool) {
		require(account != address(0));
		_totalSupply = _totalSupply += value;
		balances[account] = balances[account] + value;
		emit Transfer(address(0), account, value);
		return true;
  	}
    receive() external payable {
    // code to handle plain Ether transactions
    }
}

contract ExternalPlayer {
    GameToken public gametoken;
    address payable public owner;
    mapping(address => uint256) public exbalances;
    bool reentrancyGuard = true; 
    constructor(GameToken _gametoken) {
        gametoken = _gametoken;
        owner = payable(msg.sender);
    }
    // For players to join the game by sending ether
    function sendEtherToContract() external payable {
        require(msg.value == 1 ether, "The amount sent must be 1 ether.");
        require(reentrancyGuard);
        reentrancyGuard=false;
        // Add the sender's balance to their external balance
        exbalances[msg.sender] += msg.value;
        // Release the reentrancy guard
        reentrancyGuard=true;
    }
    // For owner to withdraw balance of the contract account
    function withdrawBalance() external {
        require(reentrancyGuard);
        require(msg.sender == owner);
        uint256 balance = address(this).balance;
        reentrancyGuard=false;
        owner.transfer(balance);
        reentrancyGuard=true;
    }
}