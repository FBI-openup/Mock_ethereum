#!/bin/bash

RPC_URL="http://129.104.49.37:8545"

export addr1=0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
export priv1=0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e

echo "Building contracts..."
forge build

echo ""
echo "Deploying Verifier..."
forge create verifier.sol:Verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL

echo ""
echo "Copy the Verifier address above and run:"
echo "export verifier=0x..."
echo ""
echo "Then deploy AccessAddr:"
echo "forge create contracts/AccessAddr.sol:AccessAddr \\"
echo "  --constructor-args \$verifier \\"
echo "  --broadcast \\"
echo "  --private-key $priv1 \\"
echo "  --rpc-url $RPC_URL"
echo ""
echo "export access=0x..."
