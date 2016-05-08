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
        Member seller;
        Member buyer;
    }    
	
	mapping (address => Member) members;
    mapping (uint => Task) tasks;
    mapping (uint => Product) products;
	
	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
    event NewTask(uint id, string name, string description);    
    event NewProduct(uint id, string name, string description);
	
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
	
	function getParameters() constant returns (address _getTreasury, address _getCommunity, uint _getIniMemberTokens, uint _getIniMemberReputation, uint _getExchange, string getName, string getSymbol, string getCommunityName, uint getBaseUnits) {
		_getTreasury = _treasury;
		_getCommunity = _community;
		_getIniMemberTokens = _iniMemberTokens;
		getName = tokenName;
		getSymbol = symbol;
		getCommunityName = communityName;
		getBaseUnits = baseUnits;
	}

	function newParameters (int _newCommunityTax, uint _newRewardRate, uint _newIniTokens, uint _newIniR) {
		if (msg.sender != _treasury) return;
		_iniMemberTokens = _newIniTokens;
	}
	
	function newCommune (address _newCommunity) {
		if (msg.sender != _treasury) return;
		_community = _newCommunity;
	}
	
	function newTreasury (address _newTreasury) {
		if (msg.sender != _community) return;
		_treasury = _newTreasury;
	}
	
    function newTask(string _name, string _description, uint _reward) public returns (uint32 taskId) {
        Task newTask = tasks[totalTasks];
        newTask.owner = members[msg.sender];
        newTask.name = _name;
        newTask.description = _description;
        newTask.status = TaskStatus.New;
        newTask.reward = _reward;
        
        totalTasks++;
        taskArray.push(totalTasks);
        
        NewTask(totalTasks, _name, _description);
        return(totalTasks);
    }
    
    function setTaskReward(uint _taskId, uint _reward, string _description) returns (bool success) {
        Task task = tasks[_taskId];
        if (task.owner.account == msg.sender) {
            task.reward = _reward;
        }
    }
    
    function getTasks() constant returns(uint32[] tList) {
        return(taskArray);
    }
    
    function getTaskName(uint id) constant returns(string tName) {
        string name = tasks[id].name;
        return(name);
    }
    
    function getTaskInfo(uint id) constant returns(string name, string description, uint reward, address owner, address volunteer, TaskStatus status){
        Task task = tasks[id];
        string taskName = task.name;
        string taskDescription = task.description;
        uint taskReward = task.reward;
        address taskOwner = task.owner.account;
        address taskVolunteer = task.volunteer.account;
        var taskStatus = task.status;
        return (taskName, taskDescription, taskReward, taskOwner, taskVolunteer, taskStatus);
    }
    
    function getMemberName(uint id) constant returns(string mName) {
        string name = members[memberArray[id]].name;
        return(name);
    }
    
    function getMemberBalance(address addr) constant returns(uint mBal){
        uint bal = members[addr].balance;
        return (bal);
    }
    
    function getTaskStatus(uint id) constant returns(string status) {
        var taskStatus = tasks[id].status;
        if (taskStatus == TaskStatus.New) {
            return("New");
        } else if (taskStatus == TaskStatus.InProgress) {
            return("In Progress");
        } else if (taskStatus == TaskStatus.Completed) {
            return("Completion Awaiting Confirmation");
        } else if (taskStatus == TaskStatus.Done) {
            return("Done");
        }
    }
    
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
    
    function newSeller(string _name) public returns(uint sellerId) {
        Member newSeller = members[msg.sender];
        newSeller.name = _name;
        newSeller.account = msg.sender;
        sellerArray.push(newSeller.account);
        
        return(sellerArray.length);
      
  }

    function newBuyer(string _name) public returns(uint buyerId) {
        Member newBuyer = members[msg.sender];
        newBuyer.name = _name;
        newBuyer.account = msg.sender;
        buyerArray.push(newBuyer.account);
        
        return(buyerArray.length);
  }

    function newProduct(string _name, string _description, uint256 _price) public returns (uint32 taskId) {
        Product newProduct = products[totalProducts];
        newProduct.seller = members[msg.sender];
        newProduct.name = _name;
        newProduct.description = _description;
        // newProduct.status = ProductStatus.New;
        newProduct.price = _price;
        
        totalProducts++;
        // productArray.push(totalProducts);
        
        NewProduct(totalProducts, _name, _description);
        return(totalProducts);
  }
  
    function setProductPrice(uint _productId, uint _price, string _description) returns (bool success) {
        Product product = products[_productId];
        if (product.seller.account == msg.sender) {
            product.price = _price;
        }
    }
        
    function getSellers() constant returns(address[] sList) {
        return(sellerArray);
    }
    
    function getProducts() constant returns(uint32[] pList) {
        return(productArray);
    }
    
    function getProductNames() constant {
        var list = productArray;
        for (uint i = 0; i < list.length; i++) {
            getProductName(i);
        }
    }
    
    function getSellerNames() constant {
        var list = sellerArray;
        for (uint i = 0; i < list.length; i++) {
            getSellerName(i);
        }
    }
    
    function getProductName(uint id) constant returns(string pName) {
        string name = products[id].name;
        return(name);
    }
    
    function getSellerName(uint id) constant returns(string sName) {
        string name = members[sellerArray[id]].name;
        return(name);
    }
    
    function getProductDescription(uint id) constant returns(string pDescription) {
        string description = products[id].description;
        return(description);
    }

    function getProductPrice(uint id) constant returns(uint price) {
        return(products[id].price);
    }
    
    function getProductSellerName(uint id) constant returns(string seller) {
        string name = products[id].seller.name;
        return(name);
    }
    
    function purchaseProduct(uint id) {
        Product product = products[id];
        if (msg.sender != product.seller.account && members[msg.sender].balance >= product.price) {
           members[msg.sender].balance -= product.price;
           members[product.seller.account].balance += product.price;
        }
    }
}