# Lab Requirements: Zero-Knowledge Access Control with Address Binding

## Original Assignment

### Context
This lab builds upon a previous ZK-proof implementation (lab2) which had a critical security flaw: the ZK-proof could be reused by someone who does not possess the secret preimage. The solution is to bind the user's identity (Ethereum address) with the secret `S`.

### Problem Statement
Design and implement a secure zero-knowledge proof-based access control system that prevents proof replay attacks by binding the proof to the sender's address.

---

## Technical Requirements

### 1. Hash Function Design

Define your own secret `S` (constant for the lab).

The new hash calculation is: **`H(H(S), H(S,I))`**

Where:
- `S` = secret (256-bit value)
- `I` = user's Ethereum address
- `H()` = SHA-256 hash function

**Implementation steps:**
1. `hs = H(S)` - Hash of secret
2. `hsa = H(S, I)` - Hash of secret combined with address
3. `h = H(hs, hsa)` - Final hash combining both

---

### 2. ZK Programs (Zokrates)

#### ComputePwdAddr.zok
Direct computation of the hash (off-chain):

```zokrates
import "hashes/sha256/512bit" as sha512bit;
import "hashes/sha256/256bitPadded.zok" as sha256bit;

def main(u32[8] addr, u32[8] s) -> (u32[8], u32[8], u32[8], u32[8]) {
  u32[8] hs = sha256bit(s);
  u32[8] hsa = sha512bit(s, addr);
  u32[8] h = sha512bit(hs, hsa);
  return (addr, h, hsa, s);
}
```

#### VerifyPwdAddr.zok
Verification API (for zero-knowledge proof):

```zokrates
import "hashes/sha256/512bit" as sha512bit;
import "hashes/sha256/256bitPadded.zok" as sha256bit;

def main(u32[8] addr, u32[8] h, u32[8] hsa, private u32[8] s) -> () {
  // TODO: Complete this file
  // Requirements:
  // 1. Check that h(S) is correct (proves knowledge of S)
  // 2. Check that hsa is correct (proves address binding)
}
```

**Tasks:**
- Complete the `VerifyPwdAddr.zok` file
- Use the output of `ComputePwdAddr.zexe` to create `VerifyPwdAddr.input`
- Use the Makefile for compiling, computing the proof, etc., "off-chain"

---

### 3. Smart Contract Modifications

#### Interface.sol
Modified from lab2 to accept 24 uint inputs instead of 8:

```diff
- function verifyTx(Proof memory, uint[8] memory) external view returns (bool);
+ function verifyTx(Proof memory, uint[24] memory) external view returns (bool);
```

#### AccessAddr.sol
Starting from lab2's `Access.sol`, create `AccessAddr.sol` with:

**Key requirements:**
1. Verify the ZK proof (as before)
2. **NEW:** Verify that `msg.sender` matches the address given in the proof inputs

**Helper functions provided:**

```solidity
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
```

---

## Infrastructure

### Network Access
- Target network: `129.104.49.37:8545` (local Ethereum instance)
- Access method: SSH to `login.dix.polytechnique.fr` (not directly accessible from outside)
- RPC URL flag required: `--rpc-url http://129.104.49.37:8545`

### Required Software
- [Foundry](https://getfoundry.sh/) - Ethereum development toolchain
- [Zokrates](https://zokrates.github.io/) - ZK-SNARK toolkit

### Deployment Notes
- `forge create` requires `--broadcast` flag
- All `cast` commands need the `--rpc-url` parameter

---

## Deliverables

Submit to instructor (daniel.augot@inria.fr):

1. **Contract address** - The deployed AccessAddr contract address
2. **Secret S** - The secret value used (generated with `cast keccak "$(openssl rand -hex 32)"`)
3. **VerifyPwdAddr.zok** - Your completed ZK verification program
4. **proving.key (pk)** - The proving key generated during setup

---

## Student Information

- **Name:** Boyuan Zhang
- **Email:** boyuan.zhang+ep@ip-paris.fr
- **Address:** 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
- **Private Key:** 0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e
