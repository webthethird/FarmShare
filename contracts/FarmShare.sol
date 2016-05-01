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
	uint _iniMemberTokens = 10; 
	
	uint _totalMinted;
	
	//tasks stuff
	uint32 public totalTasks;
    uint32[] taskArray;
    address[] ownerArray;
    address[] volunteerArray;
    
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
		baseUnits = 100;
    	tokenName = "shares";
    	symbol = "FS";
		communityName = "FarmShare";
		totalTasks = 0;
	}
	
	struct Member {
		uint balance; 
		bool isMember; 
// 		uint reputation; 
		string name; 
	}
	
    struct Owner {
        string name;
        address account;
        //uint tokenBalance;
        uint tasksCompleted;
        uint32[] taskIds_;
    }
    
    struct Volunteer {
        string name;
        address account;
        //uint tokenBalance;
        uint tasksCompleted;
        uint32[] taskIds_;
    }	
	
	struct Task {
        string name;
        string description;
        uint reward;
        Owner owner;
        Volunteer volunteer;
        TaskStatus status;
    }
    
    struct Seller {
        string name;
        address account;
        //uint tokenBalance;
    }
    
    struct Buyer {
        string name;
        address account;
        //uint tokenBalance;
    }

    struct Product {
        string name;
        string description;
        uint price;
        Seller seller;
        Buyer buyer;
    }    
	
	mapping (address => Member) balancesOf;
	mapping (address => Owner) owners;
    mapping (address => Volunteer) volunteers;
    mapping (uint => Task) tasks;
    mapping (uint => Product) products;
    mapping (address => Seller) sellers;
    mapping (address => Buyer) buyers;    
	
	event Transfer(uint _amount, address indexed _from, address indexed _to, uint _timeStampT);
	event NewMember(address indexed _member, string _alias);
	event OldMember(address indexed _exMember, string _exAlias);
    event NewTask(uint id, string name, string description);
    event NewOwner(string name, address addr);
    event NewProduct(uint id, string name, string description);
    event NewSeller(string name, address addr);
	
	function acceptMember (address _newMember, string _newName) {
        if (msg.sender != _community) return;
        balancesOf[_newMember].isMember = true;
		balancesOf[_newMember].balance = _iniMemberTokens;
 		balancesOf[_newMember].name = _newName;
		_totalMinted += _iniMemberTokens;
		NewMember(_newMember, _newName);
    }
	
	function kickOutMember (address _oldMember) {
        if (msg.sender != _community) return;        
        balancesOf[_oldMember].isMember = false;
        string _oldName = balancesOf[_oldMember].name;
        OldMember(_oldMember, _oldName);
    }
    
    function transfer (address _payee, uint _payment) {
		uint _available = balancesOf[msg.sender].balance;
		uint _amountTokens = uint(_payment); 
		if (_available > _amountTokens) {
			balancesOf[msg.sender].balance -= _amountTokens;
			balancesOf[_payee].balance += _amountTokens;
			// @notice apply community tax and send it to the Community account
			balancesOf[_payee].balance -= _amountTokens * _communityTax/100;
			balancesOf[_community].balance += _amountTokens * _communityTax/100;
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
	
    function newOwner(string _name) public returns(uint ownerId) {
        Owner newOwner = owners[msg.sender];
        newOwner.name = _name;
        newOwner.account = msg.sender;
        ownerArray.push(newOwner.account);
        
        NewOwner(newOwner.name, newOwner.account);
        return(ownerArray.length);
    }
    
    function newVolunteer(string _name) public returns(uint volunteerId) {
        Volunteer newVolunteer = volunteers[msg.sender];
        newVolunteer.name = _name;
        newVolunteer.account = msg.sender;
        volunteerArray.push(newVolunteer.account);
        
        return(volunteerArray.length);
    }
    
    function newTask(string _name, string _description, uint _reward) public returns (uint32 taskId) {
        Task newTask = tasks[totalTasks];
        newTask.owner = owners[msg.sender];
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
        Task task = tasks[_taskId - 1];
        if (task.owner.account == msg.sender) {
            task.reward = _reward;
        }
    }
        
    function getOwners() constant returns(address[] oList) {
        return(ownerArray);
    }
    
    function getTasks() constant returns(uint32[] tList) {
        return(taskArray);
    }
    
    function getTaskNames() constant {
        var list = taskArray;
        for (uint i = 0; i < list.length; i++) {
            getTaskName(i);
        }
    }
    
    function getOwnerNames() constant {
        var list = ownerArray;
        for (uint i = 0; i < list.length; i++) {
            getOwnerName(i);
        }
    }
    
    function getTaskName(uint id) constant returns(string tName) {
        string name = tasks[id - 1].name;
        return(name);
    }
    
    function getOwnerName(uint id) constant returns(string oName) {
        string name = owners[ownerArray[id]].name;
        return(name);
    }
    
    function getTaskDescription(uint id) constant returns(string tDescription) {
        string description = tasks[id - 1].description;
        return(description);
    }
    
    function getTaskStatus(uint id) constant returns(string status) {
        var taskStatus = tasks[id - 1].status;
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
    
    function getTaskRewardAmount(uint id) constant returns(uint reward) {
        return(tasks[id - 1].reward);
    }
    
    function getTaskOwnerName(uint id) constant returns(string owner) {
        string name = tasks[id - 1].owner.name;
        return(name);
    }
    
    function getTaskVolunteerName(uint id) constant returns(string volunteer) {
        string name = tasks[id - 1].volunteer.name;
        return(name);
    }
    
    function acceptTask(uint id) public returns (bool success) {
        Task task = tasks[id - 1];
        if (task.status == TaskStatus.New) {
            task.status = TaskStatus.InProgress;
            task.volunteer = volunteers[msg.sender];
            return(true);
        } else {
            return(false);
        }
    }
    
    function completeTask(uint id) public returns (string status) {
        Task task = tasks[id - 1];
        var taskStatus = "no change";
        if (msg.sender == task.volunteer.account) {
            task.status = TaskStatus.Completed;
            taskStatus = "Completion awaiting confirmation";
        } else if (msg.sender == task.owner.account && task.status != TaskStatus.Done) {
            task.status = TaskStatus.Done;
            taskStatus = "Complete";
            balancesOf[task.owner.account].balance -= task.reward;
            balancesOf[task.volunteer.account].balance += task.reward;
        }
        return (taskStatus);
    }
    
    function newSeller(string _name) public returns(uint sellerId) {
        Seller newSeller = sellers[msg.sender];
        newSeller.name = _name;
        newSeller.account = msg.sender;
        sellerArray.push(newSeller.account);
        
        NewSeller(newSeller.name, newSeller.account);
        return(sellerArray.length);
      
  }

    function newBuyer(string _name) public returns(uint buyerId) {
        Buyer newBuyer = buyers[msg.sender];
        newBuyer.name = _name;
        newBuyer.account = msg.sender;
        buyerArray.push(newBuyer.account);
        
        return(buyerArray.length);
  }

    function newProduct(string _name, string _description, uint256 _price) public returns (uint32 taskId) {
        Product newProduct = products[totalProducts];
        newProduct.seller = sellers[msg.sender];
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
        Product product = products[_productId - 1];
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
        string name = products[id - 1].name;
        return(name);
    }
    
    function getSellerName(uint id) constant returns(string sName) {
        string name = sellers[sellerArray[id]].name;
        return(name);
    }
    
    function getProductDescription(uint id) constant returns(string pDescription) {
        string description = products[id - 1].description;
        return(description);
    }

    function getProductPrice(uint id) constant returns(uint price) {
        return(products[id - 1].price);
    }
    
    function getProductSellerName(uint id) constant returns(string seller) {
        string name = products[id - 1].seller.name;
        return(name);
    }
    
    function purchaseProduct(uint id) {
        Product product = products[id - 1];
        if (msg.sender != product.seller.account && balancesOf[msg.sender].balance >= product.price) {
           balancesOf[msg.sender].balance -= product.price;
           balancesOf[product.seller.account].balance += product.price;
        }
    }
}