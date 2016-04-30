contract TaskBoard is owned, named("TaskBoard"), util, SetUtil {

    uint32 public totalTasks;
    mapping (uint => Task) tasks;
    Set_ui32 taskList;

    event NewTask(uint id, bytes32 name, bytes32 description);
    event NewOwner(bytes32 name, address addr);
    event NewSkill(bytes32 name);

    enum TaskStatus {
        New,
        InProgress,
        Completed,
        Done
    }

    Set_addr ownerList;
    Set_addr volunteerList;
    Set_addr skillList;
    mapping (address => Owner) owners;
    mapping (address => Volunteer) volunteers;
    mapping (uint => Skill) skills;

    struct Owner {
        bytes32 name;
        address account;
        uint tasksCompleted;
        Set_ui32 taskIds;
    }

    struct Volunteer {
        bytes32 name;
        address account;
        uint tasksCompleted;
        Set_ui32 taskIds;
        Set_ui32 skillIds;
    }

    struct Task {
        bytes32 name;
        bytes32 description;
        uint value;
        Owner owner;
        Volunteer volunteer;
        TaskStatus status;
        Set_ui32 requiredSkills;
    }

    struct Skill {
        bytes32 name;
    }

    function TaskBoard() {
        totalTasks = 0;
    }

    function newOwner(bytes32 _name) public returns(uint ownerId) {
        Owner newOwner = owners[msg.sender];
        newOwner.name = _name;
        newOwner.account = msg.sender;
        setAddUnique(ownerList, msg.sender);

        NewOwner(newOwner.name, newOwner.account);
        return(ownerList.arr.length);
    }

    function newVolunteer(bytes32 _name) public returns(uint volunteerId) {
        Volunteer newVolunteer = volunteers[msg.sender];
        newVolunteer.name = _name;
        newVolunteer.account = msg.sender;
        setAddUnique(volunteerList, msg.sender);
    }

    function newTask(bytes32 _name, bytes32 _description) public returns (uint32 taskId) {
        Task newTask = tasks[totalTasks];
        newTask.owner = owners[msg.sender];
        newTask.name = _name;
        newTask.description = _description;
        newTask.status = TaskStatus.New;
        newTask.value = msg.value;
        setAddUnique(ownerList, msg.sender);

        totalTasks++;
        setAddUnique(taskList, totalTasks);

        NewTask(totalTasks, _name, _description);
        return(totalTasks);
    }

    function getTasks() constant returns(uint32[] tList) {
        return(taskList.arr);
    }

    function getTaskName(uint id) constant returns(string tName) {
        bytes32 name = tasks[id - 1].name;
        return(b2s(name));
    }

    function getTaskDescription(uint id) constant returns(string tDescription) {
        bytes32 description = tasks[id - 1].description;
        return(b2s(description));
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

    function getTaskOwnerName(uint id) constant returns(string owner) {
        bytes32 name = tasks[id - 1].owner.name;
        return(b2s(name));
    }

    function getTaskVolunteerName(uint id) constant returns(string volunteer) {
        bytes32 name = tasks[id - 1].volunteer.name;
        return(b2s(name));
    }

    function getTaskTotalSkills(uint id) constant returns(uint32 totalSkils) {
        setCompact(tasks[id - 1].requiredSkills);
        return(uint32(tasks[id - 1].requiredSkills.arr.length));
    }

    function getSkillName(uint id) constant returns(string skillName) {
        bytes32 name = skills[id].name;
        return(b2s(name));
    }

    function getTaskSkills(uint id) constant returns(uint32[] list) {
        setCompact(tasks[id - 1].requiredSkills);
        return(tasks[id - 1].requiredSkills.arr);
    }

    function addTaskSkill(uint32 taskID, bytes32 name) {
        log1("addTaskSkill: ", name);
        Task task = tasks[taskID - 1];
        uint32 skillIndex = addSkill(name);
        setAddUnique(task.requiredSkills, skillIndex);
    }

    function addSkill(bytes32 name) returns (uint32 index) {
        var found = false;

        for(uint32 i = 0; i < uint32(skillList.arr.length);i++) {
            Skill storage s = skills[i];
            if(s.name == name) {
                index = i;
                found = true;
                break;
            }
        }

        if(!found) {
            log1("addSkill: ", name);
            index = uint32(skillList.arr.length);
            Skill newSkill = skills[index];
            newSkill.name = name;
            setAddUnique(skillList, index);
            NewSkill(name);
        }
        return(index);
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
        } else if (msg.sender == task.owner.account) {
            task.status = TaskStatus.Done;
            taskStatus = "Complete";
        }
        return (taskStatus);
    }
}
