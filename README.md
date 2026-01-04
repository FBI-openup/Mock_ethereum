# ZK证明访问控制实验

基于零知识证明的以太坊访问控制，通过地址绑定防止证明重用。

## 项目结构

```
etherum/
├── zokrates/
│   ├── ComputePwdAddr.zok
│   ├── VerifyPwdAddr.zok
│   └── Makefile
├── contracts/
│   └── AccessAddr.sol
├── scripts/
│   ├── deploy.sh
│   └── test_access.sh
└── foundry.toml
```

## 用户信息

```bash
export addr1=0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
export priv1=0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e
```

## 快速开始

### 1. SSH到跳板机

```bash
ssh boyuan.zhang@login.dix.polytechnique.fr
```

### 2. 安装工具

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup

curl -LSfs get.zokrat.es | sh
```

### 3. 上传项目

```bash
scp -r d:/antiGravity_workspace/etherum boyuan.zhang@login.dix.polytechnique.fr:~/
```

### 4. 生成秘密S

```bash
cast keccak "$(openssl rand -hex 32)"
```

编辑 `zokrates/Makefile`，更新 `SECRET` 变量。

### 5. ZK证明生成

```bash
cd ~/etherum/zokrates
make compute
make verify
cp verifier.sol ../contracts/
```

### 6. 部署合约

```bash
cd ~/etherum
export RPC_URL="http://129.104.49.37:8545"

forge build

forge create contracts/verifier.sol:Verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL

export verifier=0x...

forge create contracts/AccessAddr.sol:AccessAddr \
  --constructor-args $verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL

export access=0x...
```

### 7. 测试

```bash
chmod +x scripts/test_access.sh
./scripts/test_access.sh $access
```

## 哈希计算

```
hs = H(S)
hsa = H(S, addr)
h = H(hs, hsa)
```

## 提交材料

1. AccessAddr合约地址
2. 秘密S
3. `VerifyPwdAddr.zok`
4. `proving.key`

发送至：boyuan.zhang+ep@ip-paris.fr
