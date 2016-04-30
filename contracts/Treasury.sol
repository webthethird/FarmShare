import "FarmShare_Token.sol";

contract Treasury {

    mapping(address => address[]) public created;

    function createdByMe() returns (address[]) {
        return created[msg.sender];
    }

    function createToken(address _creator, uint256 _initialAmount, string _tokenName, string _redeemFor) returns (address) {

        address newTokenAddr = address(new FarmShare_Token());
        FarmShare_Token newToken = FarmShare_Token(newTokenAddr);
        newToken.transfer(msg.sender, _initialAmount); //the factory will own the created tokens. You must transfer them.
        created[msg.sender].push(newTokenAddr);
        return newTokenAddr;
    }
    
    function burnToken (address _tokenAddress) {
        FarmShare_Token(_tokenAddress).burnToken();
    }
}