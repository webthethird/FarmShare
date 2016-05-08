contract FarmShare {
	
	//token parameters
    uint baseUnits;
    string tokenName;
    string symbol;
    string communityName;

    //community parameters
    address _treasury; 
	address _community;
	uint _communityTax;
	uint _iniMemberTokens; 
	
	uint _totalMinted;
	
	//tasks stuff
	uint32 public totalTasks;
    uint32[] taskArray;
    address[] memberArray;
    
    //market stuff
    uint32 public totalProducts;
    uint32[] productArray;
    address[] sellerArray;
    address[] buyerArray;

    enum TaskStatus {
        New,
        InProgress,
        Completed,
        Done
    }

	//constructor
	function FarmShare () {
		_treasury = msg.sender;  
		_community = msg.sender;
		_totalMinted = 0;
		_iniMemberTokens = 10;
		baseUnits = 100;
    		tokenName = "shares";
    		symbol = "FS";
		communityName = "FarmShare";
		totalTasks = 0;
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
	
	struct Task {
        string name;
        string description;
        uint reward;
        Member owner;
        Member volunteer;
        TaskStatus status;
    }

    struct Product {
        string name;
        string description;
        uint price;
        uint quantity;
        Member seller;
        Member buyer;
    }    
	
	mapping (address => Member) members;
    mapping (uint => Task) tasks;
    mapping (uint => Product) products;
	
	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
    event NewTask(uint id, string name, string description, uint reward);    
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
	
	function getParameters() constant returns (address getTreasury, address getCommunity, uint getIniMemberTokens, uint getIniMemberReputation, string getName, string getSymbol, string getCommunityName) {
		getTreasury = _treasury;
		getCommunity = _community;
		getIniMemberTokens = _iniMemberTokens;
		getName = tokenName;
		getSymbol = symbol;
		getCommunityName = communityName;
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
    
    function getMemberInfo(uint id) constant returns(string name, address account, uint balance, uint reputation, uint tasks) {
        string memberName = members[memberArray[id]].name;
        address memberAcct = members[memberArray[id]].account;
        uint memberBal = members[memberArray[id]].balance;
        uint memberRep = members[memberArray[id]].reputation;
        uint memberTasks = members[memberArray[id]].tasksCompleted;
        return(memberName, memberAcct, memberBal, memberRep, memberTasks);
    }
	
	//tasks
    function newTask(string _name, string _description, uint _reward) public returns (uint32 taskId) {
        Task newTask = tasks[totalTasks];
        newTask.owner = members[msg.sender];
        newTask.name = _name;
        newTask.description = _description;
        newTask.status = TaskStatus.New;
        newTask.reward = _reward;
        
        totalTasks++;
        taskArray.push(totalTasks);
        
        NewTask(totalTasks, _name, _description, _reward);
        return(totalTasks);
    }
    
    function getTaskInfo(uint id) constant returns(string name, string description, uint reward, address owner, address volunteer, TaskStatus status){
        Task task = tasks[id];
        string taskName = task.name;
        string taskDescription = task.description;
        uint taskReward = task.reward;
        address taskOwner = task.owner.account;
        address taskVolunteer = task.volunteer.account;
        TaskStatus taskStatus = task.status;
        return (taskName, taskDescription, taskReward, taskOwner, taskVolunteer, taskStatus);
    }
    
    // function getOpenTasks() constant returns(uint[] taskList) {
    //     uint[] tList;
    //     var list = taskArray;
    //     for (uint i = 0; i < list.length; i++){
    //         if (tasks[i].status == TaskStatus.New) {
    //             tList.push(i);
    //         }
    //     }
    //     return (tList);
    // }

    function acceptTask(uint id) public returns (bool success) {
        Task task = tasks[id];
        if (task.status == TaskStatus.New) {
            task.status = TaskStatus.InProgress;
            task.volunteer = members[msg.sender];
            return(true);
        } else {
            return(false);
        }
    }
    
    function completeTask(uint id) public returns (string status) {
        Task task = tasks[id];
        var taskStatus = "no change";
        if (msg.sender == task.volunteer.account) {
            task.status = TaskStatus.Completed;
            taskStatus = "Completion awaiting confirmation";
        } else if (msg.sender == task.owner.account && task.status != TaskStatus.Done) {
            task.status = TaskStatus.Done;
            taskStatus = "Complete";
            members[task.owner.account].balance -= task.reward;
            members[task.volunteer.account].balance += task.reward;
        }
        return (taskStatus);
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