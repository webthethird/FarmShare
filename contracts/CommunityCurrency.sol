contract communityCurrency {
	
    uint baseUnits;
    string name;
    string symbol;
	string communityName;

    address _treasury; 
	address _commune;
	int _communityTax;
	int _iniMemberTokens; 
	
	int _totalMinted;

	function communityCurrency () {
		_treasury = msg.sender;  
		_commune = msg.sender;
		_totalMinted = 0;
		baseUnits = 100;
    	name = "FarmShares";
    	symbol = "FS";
		communityName = "FarmShare";
	}
	
	struct Member {
		int _balance; 
		bool _isMember; 
// 		uint _reputation; 
		string _name; 
	}
	
	mapping (address => Member) balancesOf;	
	
	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
	event Credit(address indexed _MoneyLender, address indexed _borrowerAddress, uint _cDealine, uint _endorsedUoT);
    event CreditExp(address indexed _MoneyLender, address indexed _exBorrowerAddress, uint _oldUoT , bool _success, uint _timeStampCX);
	event ClaimH(address indexed _hFrom, string _servantC, int _claimedH, uint _timeStampCH);
	event PaidH(address indexed _hTo, string _servantP, uint _paidH, uint _timeStampPH);
	
	function acceptMember (address _newMember, string _newName) {
        if (msg.sender != _commune) return;
        balancesOf[_newMember]._isMember = true;
		balancesOf[_newMember]._balance = _iniMemberTokens;
 		balancesOf[_newMember]._name = _newName;
		_totalMinted += _iniMemberTokens;
		NewMember(_newMember, _newName);
    }
	
	function kickOutMember (address _oldMember) {
        if (msg.sender != _commune) return;        
        balancesOf[_oldMember]._isMember = false;
        string _oldName = balancesOf[_oldMember]._name;
        OldMember(_oldMember, _oldName);
    }
    
    function transfer (address _payee, uint _payment) {
		int _available = balancesOf[msg.sender]._balance;
		int _amountCCUs = int(_payment); 
		if (_available > _amountCCUs) {
			balancesOf[msg.sender]._balance -= _amountCCUs;
			balancesOf[_payee]._balance += _amountCCUs;
			// @notice apply community tax and send it to the Community account
			balancesOf[_payee]._balance -= _amountCCUs * _communityTax/100;
			balancesOf[_commune]._balance += _amountCCUs * _communityTax/100;
			Transfer(_payment, msg.sender, _payee, now);
		}
	}
	
	function getParameters() constant returns (address _getTreasury, address _getCommunity, int _getIniMemberTokens, uint _getIniMemberReputation, uint _getExchange, string getName, string getSymbol, string getCommunityName, uint getBaseUnits) {
		_getTreasury = _treasury;
		_getCommunity = _commune;
		_getIniMemberTokens = _iniMemberTokens;
		getName = name;
		getSymbol = symbol;
		getCommunityName = communityName;
		getBaseUnits = baseUnits;
	}

	function newParameters (int _newDemurrage, uint _newRewardRate, int _newIniTokens, uint _newIniR) {
		if (msg.sender != _treasury) return;
		_iniMemberTokens = _newIniTokens;
	}
	
	function newCommune (address _newCommune) {
		if (msg.sender != _treasury) return;
		_commune = _newCommune;
	}
	
	function newTreasury (address _newTreasury) {
		if (msg.sender != _commune) return;
		_treasury = _newTreasury;
	}
}