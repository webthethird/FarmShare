contract ContractManagerEnabled {
  address CM;

  function setCMAddress(address cmAddr) returns (bool result){
    if(CM != 0x0 && msg.sender != CM){
      return false;
    }
    CM = cmAddr;
    return true;
  }

  function remove(){
    if(msg.sender == CM){
      suicide(CM);
    }
  }
}

contract ContractManager {
  address owner;

  mapping (bytes32 => address) public contracts;

  modifier onlyOwner {
    if(msg.sender == owner)
    _
  }

  function ContractManager(){
    owner = msg.sender;
  }

  function addContract(bytes32 name, address addr) onlyOwner returns (bool result) {
    ContractManagerEnabled cme = ContractManagerEnabled(addr);
    if(!cme.setCMAddress(address(this))) {
      return false;
    }
    contracts[name] = addr;
    return true;
  }

  function removeContract(bytes32 name) onlyOwner returns (bool result){
    if (contracts[name] == 0x0){
      return false;
    }
    contracts[name] = 0x0;
    return true;
  }

  function remove() onlyOwner {
    address fs = contracts["farmshare"];
    address tb = contracts["taskboard"];

    if(fs != 0x0){ContractManagerEnabled(fs).remove(); }
    if(tb != 0x0){ContractManagerEnabled(tb).remove(); }

    suicide(owner);
  }
}

contract ContractProvider {
  function contracts(bytes32 name) returns (address addr) {}
}
