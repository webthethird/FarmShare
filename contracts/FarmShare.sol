import "ContractManager.sol";

contract FarmShareInterface {
	function transfer(address _payee, uint _payment) {}

	function getParameters() constant returns (address getTreasury, address getCommunity, uint getIniMemberTokens, uint getIniMemberReputation, string get_tokenName, string get_communityName) {}

	function newParameters (int _newCommunityTax, uint _newRewardRate, uint _newIniTokens, uint _newIniR) {}

	function newCommunity (address _newCommunity) {}

	function newTreasury (address _newTreasury) {}

	function acceptMember (address _newMember, string _newName) {}

	function kickOutMember (address _oldMember) {}

	function getMemberInfo(address addr) constant returns(string name, address account, bool status, uint balance, uint reputation, uint tasks) {}

	function newProduct(string _name, string _description, uint256 _price, uint _quantity) public returns (uint32 prodId) {}

	function getProductInfo(uint id) constant returns(string name, string seller, string description, uint price, uint quantity) {}

	function purchaseProduct(uint id, uint quant) {}

	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
	event NewProduct(uint id, string name, string description, uint price, uint quantity);
}

contract FarmShare is FarmShareInterface {

	//token parameters
	uint _baseUnits;
	string _tokenName;
	string _symbol;
	string _communityName;

	//community parameters
	address _treasury;
	address _community;
	uint _communityTax;
	uint _iniMemberTokens;
	uint _iniMemberRep;

	uint _totalMinted;

	address[] memberArray;

	//market stuff
	uint32 public totalProducts;
	uint32[] productArray;
	address[] sellerArray;
	address[] buyerArray;

	//constructor
	function FarmShare () {
		_treasury = msg.sender;
		_community = msg.sender;
		_totalMinted = 0;
		_iniMemberTokens = 100;
		_iniMemberRep = 100;
		_baseUnits = 100;
		_tokenName = "shares";
		_symbol = "FS";
		_communityName = "FarmShare";
	}

	struct Member {
		string name;
		uint reputation;
		uint balance;
		bool isMember;
		address account;
		uint tasksCompleted;
		uint32[] taskIds;
	}

	struct Product {
		string name;
		string description;
		uint price;
		uint quantity;
		Member seller;
		Member buyer;
	}

	mapping (address => Member) public members;
	mapping (uint => Product) products;

	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
	event NewProduct(uint id, string name, string description, uint price, uint quantity);

	function transfer (address _payee, uint _payment) {
		uint _available = members[msg.sender].balance;
		uint _amountTokens = uint(_payment);
		if (_available > _amountTokens) {
			members[msg.sender].balance -= _amountTokens;
			members[_payee].balance += _amountTokens;
			// @notice apply community tax and send it to the Community account
			members[_payee].balance -= _amountTokens * _communityTax/100;
			members[_community].balance += _amountTokens * _communityTax/100;
			Transfer(_payment, msg.sender, _payee, now);
		}
	}

	function getParameters() constant returns (address getTreasury, address getCommunity, uint getIniMemberTokens, uint getIniMemberReputation, string get_tokenName, string get_communityName) {
		getTreasury = _treasury;
		getCommunity = _community;
		getIniMemberTokens = _iniMemberTokens;
		getIniMemberReputation = _iniMemberRep;
		get_tokenName = _tokenName;
		get_communityName = _communityName;
	}

	function newParameters (int _newCommunityTax, uint _newRewardRate, uint _newIniTokens, uint _newIniR) {
		if (msg.sender != _treasury) return;
		_iniMemberTokens = _newIniTokens;
	}

	function newCommunity (address _newCommunity) {
		if (msg.sender != _treasury) return;
		_community = _newCommunity;
	}

	function newTreasury (address _newTreasury) {
		if (msg.sender != _community) return;
		_treasury = _newTreasury;
	}

	//membership
	function acceptMember (address _newMember, string _newName) {
		if (msg.sender != _community) return;
		members[_newMember].account = _newMember;
		members[_newMember].isMember = true;
		members[_newMember].balance = _iniMemberTokens;
		members[_newMember].name = _newName;
		memberArray.push(_newMember);
		_totalMinted += _iniMemberTokens;
		NewMember(_newMember, _newName);
	}

	function kickOutMember (address _oldMember) {
		if (msg.sender != _community) return;
		members[_oldMember].isMember = false;
		string _oldName = members[_oldMember].name;
		OldMember(_oldMember, _oldName);
	}

	function getMemberInfo(address addr) constant returns(string name, address account, bool status, uint balance, uint reputation, uint tasks) {
		Member member = members[addr];
		string memberName = member.name;
		address memberAcct = member.account;
		bool memberStatus = member.isMember;
		uint memberBal = member.balance;
		uint memberRep = member.reputation;
		uint memberTasks = member.tasksCompleted;
		return(memberName, memberAcct, memberStatus, memberBal, memberRep, memberTasks);
	}

		//market
	function newProduct(string _name, string _description, uint256 _price, uint _quantity) public returns (uint32 prodId) {
		Product newProduct = products[totalProducts];
		newProduct.seller = members[msg.sender];
		newProduct.name = _name;
		newProduct.description = _description;
		newProduct.price = _price;
		newProduct.quantity = _quantity;

		totalProducts++;
		// productArray.push(totalProducts);

		NewProduct(totalProducts, _name, _description, _price, _quantity);
		return(totalProducts);
	}

	function getProductInfo(uint id) constant returns(string name, string seller, string description, uint price, uint quantity) {
		Product prod = products[id];
		name = prod.name;
		seller = prod.seller.name;
		description = prod.description;
		price = prod.price;
		quantity = prod.quantity;
		return (name, seller, description, price, quantity);
	}

	function purchaseProduct(uint id, uint quant) {
		Product product = products[id];
		if (msg.sender != product.seller.account && members[msg.sender].balance >= product.price*quant && product.quantity > quant) {
			members[msg.sender].balance -= product.price*quant;
			members[product.seller.account].balance += product.price*quant;
			product.quantity -= quant;
		}
	}
}
