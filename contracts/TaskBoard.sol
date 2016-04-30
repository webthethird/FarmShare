import "Treasury.sol";


//adapted from JobMarket contract by ultra-koder: https://github.com/ultra-koder/JobMarket/blob/master/dapp/contracts/jobmarket.sol
contract TaskBoard {
    address public tokenAddress;
    
    uint32 public totalTasks;
    mapping (uint => Task) tasks;
    uint32[] taskArray;
    
    event NewTask(uint id, string name, string description);
    event NewOwner(string name, address addr);
    //event NewSkill(bytes32 name);
    
    enum TaskStatus {
        New,
        InProgress,
        Completed,
        Done
    }
    
    address[] ownerArray;
    address[] volunteerArray;
    
    mapping (address => Owner) owners;
    mapping (address => Volunteer) volunteers;
    //mapping (uint => Skill) skills;
    
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
        uint value;
        uint rewardAmount;
        string rewardName;
        string rewardDescription;
        Owner owner;
        Volunteer volunteer;
        TaskStatus status;
    }
    
    // struct Skill {
    //     bytes32 name;
    // }
    
    function TaskBoard() {
        totalTasks = 0;
        address treasuryAddress = address(new Treasury());
        Treasury treasury = Treasury(treasuryAddress);
        
        //tokenAddress = treasury.createToken();
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
    
    function newTask(string _name, string _description) public returns (uint32 taskId) {
        Task newTask = tasks[totalTasks];
        newTask.owner = owners[msg.sender];
        newTask.name = _name;
        newTask.description = _description;
        newTask.status = TaskStatus.New;
        newTask.value = msg.value;
        
        
        totalTasks++;
        taskArray.push(totalTasks);
        
        NewTask(totalTasks, _name, _description);
        return(totalTasks);
        

    }
    
    // function setTokenAddress(address _tokenAddress) public onlyowner returns(bool success) {
    //     tokenAddress = _tokenAddress;
    //     return true;
    // }
    
    function setTaskReward(uint _taskId, uint _rewardAmount, string _rewardName, string _description) returns (bool success) {
        Task task = tasks[_taskId - 1];
        if (task.owner.account == msg.sender) {
            task.rewardAmount = _rewardAmount;
            task.rewardName = _rewardName;
            task.rewardDescription = _description;
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
    
    function getTaskValue(uint id) constant returns(uint value) {
        return(tasks[id - 1].value);
    }
    
    function getTaskRewardAmount(uint id) constant returns(uint reward) {
        return(tasks[id - 1].rewardAmount);
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
           // balanceOf[tokenAddress] -= task.reward;
           // balanceOf[task.volunteer.account] += task.reward;
        }
        return (taskStatus);
    }
}