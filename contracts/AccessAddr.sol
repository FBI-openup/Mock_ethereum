pragma solidity ^0.8.26;

interface IVerifier {
    struct Proof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }
    
    function verifyTx(Proof memory proof, uint[24] memory input) external view returns (bool);
}

contract AccessAddr {
    IVerifier public verifier;
    mapping(address => uint256) public accessLog;
    uint256 public totalAccesses;
    
    event AccessGranted(address indexed user, uint256 timestamp);
    
    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }
    
    function accessAddr(
        IVerifier.Proof memory proof,
        uint[24] memory input
    ) public returns (bool) {
        require(compare(input, msg.sender), "Address mismatch");
        
        require(verifier.verifyTx(proof, input), "Invalid proof");
        
        accessLog[msg.sender] = block.timestamp;
        totalAccesses++;
        emit AccessGranted(msg.sender, block.timestamp);
        
        return true;
    }
    
    function compare(uint[24] memory input, address addr) public pure returns (bool) {
        uint32[8] memory addr_b = addressToBytes(addr);
        for (uint i = 0; i < 8; ++i){
            if (addr_b[i] != uint32(input[7-i])) {
                return false;
            }
        }
        return true;
    }

    function addressToBytes(address addr) public pure returns (uint32[8] memory){
        uint256 addr_i = uint256(uint160(addr));
        uint256 B = 0x100000000;
        uint32[8] memory result;
        for(uint i = 0; i < 8; ++i) {
            result[i] = uint32(addr_i % B);
            addr_i = addr_i / B;
        }
        return result;
    }
    
    function getBalance(address addr) public view returns (uint256) {
        return accessLog[addr];
    }
}

