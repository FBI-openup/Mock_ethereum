#!/bin/bash

echo "========================================="
echo "ZK Access Control - Complete Test Script"
echo "========================================="
echo ""

RPC_URL="http://129.104.49.37:8545"
priv1=0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e
addr1=0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504

echo "Step 1: Testing RPC connection..."
cast block-number --rpc-url $RPC_URL
if [ $? -ne 0 ]; then
  echo "ERROR: Cannot connect to RPC"
  exit 1
fi
echo "✓ RPC connection OK"
echo ""

echo "Step 2: Checking account balance..."
balance=$(cast balance $addr1 --rpc-url $RPC_URL)
echo "Balance: $balance Wei"
if [ "$balance" == "0" ]; then
  echo "WARNING: Account has no balance"
fi
echo ""

echo "Step 3: Generating SECRET..."
SECRET=$(cast keccak "$(openssl rand -hex 32)")
echo "SECRET: $SECRET"
echo ""

echo "Step 4: Testing Zokrates..."
cd zokrates
sed -i "s/SECRET = CHANGE_ME/SECRET = $SECRET/" Makefile
echo "Running make compute..."
make compute
if [ $? -ne 0 ]; then
  echo "ERROR: make compute failed"
  exit 1
fi
echo "✓ Compute successful"
echo ""

echo "Running make verify..."
make verify
if [ $? -ne 0 ]; then
  echo "ERROR: make verify failed"
  exit 1
fi
echo "✓ Verify successful"
echo ""

if [ ! -f "verifier.sol" ]; then
  echo "ERROR: verifier.sol not generated"
  exit 1
fi
echo "✓ verifier.sol generated"
echo ""

echo "Step 5: Copying verifier to contracts..."
cp verifier.sol ../contracts/
cd ..
echo ""

echo "Step 6: Building with Forge..."
forge build
if [ $? -ne 0 ]; then
  echo "ERROR: forge build failed"
  exit 1
fi
echo "✓ Forge build successful"
echo ""

echo "Step 7: Deploying Verifier contract..."
verifier_output=$(forge create contracts/verifier.sol:Verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL 2>&1)

verifier=$(echo "$verifier_output" | grep "Deployed to:" | awk '{print $3}')
if [ -z "$verifier" ]; then
  echo "ERROR: Failed to deploy Verifier"
  echo "$verifier_output"
  exit 1
fi
echo "✓ Verifier deployed: $verifier"
echo ""

echo "Step 8: Deploying AccessAddr contract..."
access_output=$(forge create contracts/AccessAddr.sol:AccessAddr \
  --constructor-args $verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL 2>&1)

access=$(echo "$access_output" | grep "Deployed to:" | awk '{print $3}')
if [ -z "$access" ]; then
  echo "ERROR: Failed to deploy AccessAddr"
  echo "$access_output"
  exit 1
fi
echo "✓ AccessAddr deployed: $access"
echo ""

echo "Step 9: Testing contract functions..."

echo "Test 1: totalAccesses"
total=$(cast call $access "totalAccesses()(uint256)" --rpc-url $RPC_URL)
echo "Total accesses: $total"

echo "Test 2: verifier address"
verifier_check=$(cast call $access "verifier()(address)" --rpc-url $RPC_URL)
echo "Verifier address: $verifier_check"

echo "Test 3: getBalance"
balance_check=$(cast call $access "getBalance(address)(uint256)" $addr1 --rpc-url $RPC_URL)
echo "Balance for $addr1: $balance_check"
echo ""

echo "========================================="
echo "ALL TESTS PASSED!"
echo "========================================="
echo ""
echo "Deployment Info:"
echo "Verifier:   $verifier"
echo "AccessAddr: $access"
echo "SECRET:     $SECRET"
echo ""
echo "Saving to deployment_info.txt..."
echo "Verifier: $verifier" > deployment_info.txt
echo "AccessAddr: $access" >> deployment_info.txt
echo "SECRET: $SECRET" >> deployment_info.txt
