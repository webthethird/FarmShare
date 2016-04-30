contract communityCurrency {
	
    uint baseUnits;
    string name;
    string symbol;
	string communityName;

    address _treasury; 
	address _commune;
	int _communityTax;
	int _iniMemberCCUs; 
	uint _iniMemberReputation;

	uint _goalDemurrage;
	uint _goalCrowdFunding;
	uint _goalCommunityHours;
	uint _goalExpenses;
	int _realDemurrage;
	uint _realCrowdFunding;
	int _realCommunityHours;
	uint _realExpenses;
	
	int _totalMinted;
	uint _totalCredit;
	uint _totalTrustCost;
	uint _totalTrustAvailable;

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
		int _CCUs; 
		bool _isMember; 
// 		uint _reputation; 
		string _alias; 
	}
	
	mapping (address => Member) balancesOf;	
	
	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
	event Credit(address indexed _MoneyLender, address indexed _borrowerAddress, uint _cDealine, uint _endorsedUoT);
    event CreditExp(address indexed _MoneyLender, address indexed _exBorrowerAddress, uint _oldUoT , bool _success, uint _timeStampCX);
	event ClaimH(address indexed _hFrom, string _servantC, int _claimedH, uint _timeStampCH);
	event PaidH(address indexed _hTo, string _servantP, uint _paidH, uint _timeStampPH);
	
	function acceptMember (address _newMember, string _newAlias) {
        if (msg.sender != _commune) return;
        balancesOf[_newMember]._isMember = true;
		balancesOf[_newMember]._CCUs = _iniMemberCCUs;
 		balancesOf[_newMember]._alias = _newAlias;
		_totalMinted += _iniMemberCCUs;
		NewMember(_newMember, _newAlias);
    }
	
	function kickOutMember (address _oldMember) {
        if (msg.sender != _commune) return;        
        balancesOf[_oldMember]._isMember = false;
        string _oldAlias = balancesOf[_oldMember]._alias;
        OldMember(_oldMember, _oldAlias);
    }
    
    function transfer (address _payee, uint _payment) {
		int _available = balancesOf[msg.sender]._CCUs;
		int _amountCCUs = int(_payment); 
		if (_available > _amountCCUs) {
			balancesOf[msg.sender]._CCUs -= _amountCCUs;
			balancesOf[_payee]._CCUs += _amountCCUs;
			// @notice apply community tax and send it to the Community account
			balancesOf[_payee]._CCUs -= _amountCCUs * _communityTax/100;
			balancesOf[_commune]._CCUs += _amountCCUs * _communityTax/100;
			Transfer(_payment, msg.sender, _payee, now);
		}
	}
	
	function getParameters() constant returns (address _getTreasury, address _getCommunity, int _getIniMemberCCUs, uint _getIniMemberReputation, uint _getExchange, string getName, string getSymbol, string getCommunityName, uint getBaseUnits) {
		_getTreasury = _treasury;
		_getCommunity = _commune;
		_getIniMemberCCUs = _iniMemberCCUs;
		_getIniMemberReputation = _iniMemberReputation;
		getName = name;
		getSymbol = symbol;
		getCommunityName = communityName;
		getBaseUnits = baseUnits;
	}
	
	function getMoneyTotals() constant returns (int _getTotalMinted, uint _getTotalCredit, uint _getTotalTrustCost, uint _getTotalTrustAvailable) {
		_getTotalMinted = _totalMinted;
		_getTotalCredit = _totalCredit;
		_getTotalTrustCost = _totalTrustCost;
		_getTotalTrustAvailable = _totalTrustAvailable;
	}

	function newParameters (int _newDemurrage, uint _newRewardRate, int _newIniCCUs, uint _newIniR) {
		if (msg.sender != _treasury) return;
		_iniMemberCCUs = _newIniCCUs;
		_iniMemberReputation = _newIniR;
	}
	
	function newCommune (address _newCommune) {
		if (msg.sender != _treasury) return;
		_commune = _newCommune;
	}
	
	function newTreasury (address _newTreasury) {
		if (msg.sender != _commune) return;
		_treasury = _newTreasury;
	}
	
	function getBudget() constant returns (uint _getGoalDemurrage, uint _getGoalCrowdFunding, uint _getGoalCommunityHours, uint _getGoalExpenses, int _getRealDemurrage, uint _getRealCrowdFunding, int _getRealCommunityHours, uint _getRealExpenses, int _getCommuneBalance, int _getTreasuryBalance) {
			_getGoalDemurrage = _goalDemurrage;
			_getGoalCrowdFunding = _goalCrowdFunding;
			_getGoalCommunityHours = _goalCommunityHours;
			_getGoalExpenses = _goalExpenses;
			_getRealDemurrage = _realDemurrage;
			_getRealCrowdFunding = _realCrowdFunding;
			_getRealCommunityHours = _realCommunityHours;
			_getRealExpenses = _realExpenses;
			_getCommuneBalance = balancesOf[_commune]._CCUs;
			_getTreasuryBalance = balancesOf[_treasury]._CCUs;
		}

	function setNewBudget (uint _newGoalDemurrage, uint _newGoalCrowdFunding, uint _newGoalCommunityHours, uint _newGoalExpenses) {
			_goalDemurrage = _newGoalDemurrage;
			_goalCrowdFunding = _newGoalCrowdFunding;
			_goalCommunityHours = _newGoalCommunityHours;
			_goalExpenses = _newGoalExpenses;
			_realDemurrage = 0;
			_realCrowdFunding = 0;
			_realCommunityHours = 0;
			_realExpenses = 0;		
		}
}