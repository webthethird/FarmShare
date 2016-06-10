import "ContractManager.sol";
import "FarmShare.sol";

contract TaskBoard is FarmShare, ContractManagerEnabled {
  uint32 public totalTasks;
  uint32[] taskArray;
  address farmshare;

  function taskBoard() {
    farmshare = ContractProvider(CM).contracts("farmshare");
		totalTasks = 0;
  }

  enum TaskStatus {
    New,
    InProgress,
    Completed,
    Done
  }

  struct Task {
    string name;
    string description;
    uint reward;
    address owner;
    address volunteer;
    TaskStatus status;
  }

  mapping (uint => Task) tasks;

  event NewTask(uint id, string name, string description, uint reward);

  function newTask(string _name, string _description, uint _reward) public returns (uint32 taskId) {
    address farmshare = ContractProvider(CM).contracts("farmshare");
		Task newTask = tasks[totalTasks];
		newTask.owner = msg.sender;
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
		address taskOwner = task.owner;
		address taskVolunteer = task.volunteer;
		TaskStatus taskStatus = task.status;
		return (taskName, taskDescription, taskReward, taskOwner, taskVolunteer, taskStatus);
	}

  function acceptTask(uint id) public returns (bool success) {
    Task task = tasks[id];
    if (task.status == TaskStatus.New) {
      task.status = TaskStatus.InProgress;
      task.volunteer = msg.sender;
      return(true);
    } else {
      return(false);
    }
  }

  function completeTask(uint id) public returns (string status) {
    Task task = tasks[id];
    var taskStatus = "no change";
    if (msg.sender == task.volunteer) {
      task.status = TaskStatus.Completed;
      taskStatus = "Completion awaiting confirmation";
    } else if (msg.sender == task.owner && task.status != TaskStatus.Done) {
      task.status = TaskStatus.Done;
      taskStatus = "Complete";
      // members[task.owner.account].balance -= task.reward;
      // members[task.volunteer.account].balance += task.reward;
    }
    return (taskStatus);
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


}
