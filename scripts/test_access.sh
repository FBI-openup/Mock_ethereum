#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: ./test_access.sh <ACCESS_CONTRACT_ADDRESS>"
  exit 1
fi

access=$1
RPC_URL="http://129.104.49.37:8545"
addr1=0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504

echo "Testing AccessAddr contract: $access"
echo ""

echo "Check total accesses:"
cast call $access "totalAccesses()(uint256)" --rpc-url $RPC_URL

echo ""
echo "Check balance for $addr1:"
cast call $access "getBalance(address)(uint256)" $addr1 --rpc-url $RPC_URL

echo ""
echo "Get contract balance:"
cast balance $access --rpc-url $RPC_URL
