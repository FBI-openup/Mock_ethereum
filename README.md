# Zero-Knowledge Access Control with Address Binding

A secure implementation of zero-knowledge proof-based access control for Ethereum, preventing proof replay attacks through address-binding cryptography.

## Overview

This project demonstrates an improved ZK-SNARK access control system that addresses a critical vulnerability in traditional zero-knowledge authentication: **proof reusability**. By binding the proof to the sender's Ethereum address, we ensure that a valid proof cannot be stolen and reused by malicious actors.

### Key Innovation

**Problem:** Traditional ZK proofs for authentication can be intercepted and replayed by attackers who don't possess the secret.

**Solution:** Cryptographically bind the proof to both the secret `S` and the user's address `I` using a composite hash: `H(H(S), H(S,I))`

This creates a proof that is:
- ✅ Valid only for the specific address
- ✅ Non-transferable between users
- ✅ Zero-knowledge (secret never revealed)

---

## Architecture

### 1. Cryptographic Hash Structure

```
Input: Secret S, Address I
├─> hs = H(S)           # Proves knowledge of secret
├─> hsa = H(S, I)       # Binds secret to address  
└─> h = H(hs, hsa)      # Final composite hash
```

**Why this works:**
- `H(S)` proves the user knows the secret
- `H(S, I)` binds the proof to their specific address
- `H(H(S), H(S,I))` combines both properties
- An attacker without `S` cannot forge a valid proof for their address

### 2. Zero-Knowledge Circuits (Zokrates)

#### Off-Chain Computation (`ComputePwdAddr.zok`)
Computes the complete hash chain to generate public inputs:
- **Inputs:** `addr` (address), `s` (secret)
- **Outputs:** `(addr, h, hsa, s)` - used to generate proof inputs

#### Proof Verification (`VerifyPwdAddr.zok`)
ZK circuit that verifies without revealing the secret:
- **Public inputs:** `addr`, `h`, `hsa`
- **Private witness:** `s` (never revealed on-chain)
- **Constraints:** 
  - `assert(sha256(s) == hs_derived)`
  - `assert(sha512(s, addr) == hsa)`
  - `assert(sha512(hs_derived, hsa) == h)`

### 3. Smart Contract (`AccessAddr.sol`)

On-chain verification with two-layer security:

```solidity
function accessAddr(Proof memory proof, uint[24] memory input) public returns (bool) {
    // Layer 1: Verify address matches sender
    require(compare(input, msg.sender), "Address mismatch");
    
    // Layer 2: Verify ZK proof
    require(verifier.verifyTx(proof, input), "Invalid proof");
    
    // Grant access
    accessLog[msg.sender] = block.timestamp;
    return true;
}
```

**Security properties:**
1. **Address binding:** Proof includes sender address in public inputs
2. **On-chain verification:** Contract checks `msg.sender == addr_in_proof`
3. **ZK verification:** Verifier contract validates SNARK proof
4. **Replay protection:** Each proof is bound to specific address

---

## Implementation

### Project Structure

```
etherum/
├── zokrates/
│   ├── ComputePwdAddr.zok    # Off-chain hash computation
│   ├── VerifyPwdAddr.zok      # ZK verification circuit
│   └── Makefile               # Build automation
├── contracts/
│   └── AccessAddr.sol         # On-chain access control
├── test_all.sh                # Comprehensive test suite
└── foundry.toml               # Foundry configuration
```

### Key Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| **Zokrates Circuits** | Generate and verify ZK proofs | ZK-SNARKs (Groth16) |
| **Smart Contract** | On-chain verification & access control | Solidity 0.8.20 |
| **Test Suite** | End-to-end integration testing | Bash, Foundry, Zokrates |

---

## Usage

### Prerequisites

1. Access to `login.dix.polytechnique.fr` (SSH gateway)
2. Installed tools: [Foundry](https://getfoundry.sh/), [Zokrates](https://zokrates.github.io/)
3. RPC endpoint: `http://129.104.49.37:8545`

### Quick Start

1. **Clone and navigate:**
   ```bash
   git clone https://github.com/FBI-openup/Mock_ethereum.git etherum
   cd etherum
   ```

2. **Run complete test suite:**
   ```bash
   chmod +x test_all.sh
   ./test_all.sh
   ```

   This will:
   - ✓ Test RPC connection
   - ✓ Generate random SECRET
   - ✓ Compile Zokrates circuits
   - ✓ Compute witness
   - ✓ Setup proving scheme (generates `proving.key`)
   - ✓ Export Solidity verifier
   - ✓ Build contracts with Forge
   - ✓ Deploy Verifier and AccessAddr contracts
   - ✓ Run integration tests

3. **Check results:**
   ```bash
   cat deployment_info.txt
   ```
   Contains: Contract addresses and SECRET used

---

## Technical Details

### Input/Output Specifications

#### Zokrates Circuits

**ComputePwdAddr.zok**
- Input: `u32[8] addr`, `u32[8] s`
- Output: `(u32[8] addr, u32[8] h, u32[8] hsa, u32[8] s)`

**VerifyPwdAddr.zok**
- Public: `u32[8] addr`, `u32[8] h`, `u32[8] hsa`
- Private: `u32[8] s`
- Output: `()` (constraints satisfied or circuit fails)

#### Smart Contract

**AccessAddr.accessAddr()**
- Input: `Proof memory proof`, `uint[24] memory input`
  - `input[0:7]` = address (8 × u32)
  - `input[8:15]` = h (8 × u32)
  - `input[16:23]` = hsa (8 × u32)
- Returns: `bool` (access granted)
- Emits: `AccessGranted(address user, uint256 timestamp)`

### Address Encoding

Ethereum addresses (160 bits) are encoded as 8 × 32-bit unsigned integers (little-endian):

```javascript
// Example: 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
address_u32 = [3609421060, 2972776900, 2314349482, 1262427657, 4289641753, 0, 0, 0]
```

Conversion logic in Solidity:
```solidity
function addressToBytes(address addr) public pure returns (uint32[8] memory) {
    uint256 addr_i = uint256(uint160(addr));
    uint256 B = 0x100000000; // 2^32
    uint32[8] memory result;
    for(uint i = 0; i < 8; ++i) {
        result[i] = uint32(addr_i % B);
        addr_i = addr_i / B;
    }
    return result;
}
```

---

## Security Analysis

### Threat Model

| Attack Vector | Mitigation | Status |
|---------------|------------|--------|
| **Proof Replay** | Address binding in proof | ✅ Mitigated |
| **Proof Forgery** | ZK-SNARK cryptography | ✅ Secure |
| **Secret Extraction** | Zero-knowledge property | ✅ Protected |
| **Address Spoofing** | `msg.sender` validation | ✅ Prevented |

### Cryptographic Properties

1. **Zero-Knowledge:** Verifier learns nothing about `S`
2. **Soundness:** Cannot forge proof without knowing `S`
3. **Completeness:** Valid proof always verifies
4. **Address Binding:** Proof is specific to sender address

### Constraints

- **Circuit complexity:** 81,042 R1CS constraints (VerifyPwdAddr)
- **Proof size:** ~200 bytes (Groth16)
- **Gas cost:** ~280,000 gas for verification

---

## Testing

The `test_all.sh` script provides comprehensive end-to-end testing:

### Test Coverage

1. **Infrastructure Tests**
   - RPC connectivity
   - Account balance verification

2. **ZK Circuit Tests**
   - ComputePwdAddr compilation
   - Witness generation
   - VerifyPwdAddr compilation
   - Setup (proving/verification keys)
   - Verifier export

3. **Smart Contract Tests**
   - Forge compilation
   - Contract deployment (Verifier + AccessAddr)
   - Function tests:
     - `totalAccesses()`
     - `verifier()` getter
     - `getBalance(address)`

### Example Output

```
=========================================
ZK Access Control - Complete Test Script
=========================================

Step 1: Testing RPC connection...
91
✓ RPC connection OK

...

Step 10: Testing contract functions...
Total accesses: 0
Verifier address: 0xf479...
Balance for 0xfFAe...: 0

=========================================
ALL TESTS PASSED!
=========================================

Deployment Info:
Verifier:   0xf479c53bD6e4488e23730D2892EeD972f330Af8D
AccessAddr: 0xDcBE5eFfB51A3Cd0040B81bc5171b9C54B44050B
SECRET:     0x7e8e8d4ef781a57a0fa1835bdcdd4340c9c8f8c353180587f19b8ec84e7a609a
```

---

## Knowledge Points

### 1. Zero-Knowledge Proofs (ZK-SNARKs)
- **Non-interactive proofs:** Single message proves statement
- **Succinctness:** Constant-size proof (~200 bytes)
- **Zero-knowledge:** No information leaked beyond validity

### 2. Hash Functions in ZK Circuits
- **SHA-256:** Collision-resistant, but expensive in circuits
- **Pedersen hash:** ZK-friendly alternative (not used here)
- **Trade-off:** Security vs. circuit complexity

### 3. Ethereum Address Encoding
- **160-bit addresses:** Requires 5 × 32-bit words (padded to 8)
- **Little-endian encoding:** LSB first for compatibility
- **Type conversions:** `address → uint160 → uint256 → uint32[]`

### 4. Smart Contract Security
- **`msg.sender` trust:** Ethereum provides authentic sender
- **Re-entrancy:** Not applicable (view-only verifier)
- **Gas optimization:** Pre-compiled contracts for pairings

### 5. Foundry Development
- **`forge create`:** Contract deployment CLI
- **`cast`:** Blockchain interaction tool
- **`--broadcast`:** Required for transaction submission

---

## References

- **Original Lab:** INF571 - Zero-Knowledge Cryptography
- **ZK-SNARKs:** [Groth16](https://eprint.iacr.org/2016/260.pdf) proving system
- **Zokrates:** [Documentation](https://zokrates.github.io/)
- **Foundry:** [Book](https://book.getfoundry.sh/)

---

## License

Educational project for INF571 course at École Polytechnique.

## Author

**Boyuan Zhang**  
Email: boyuan.zhang+ep@ip-paris.fr  
Address: 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
