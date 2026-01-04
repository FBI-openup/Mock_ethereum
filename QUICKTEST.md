# 快速测试指南

由于本地Windows没有安装工具，所有测试需要在**跳板机**上进行。

## 步骤总览

```
1. SSH连接 → 2. 安装工具 → 3. 上传项目 → 4. 生成ZK证明 → 5. 部署合约 → 6. 测试功能
```

---

## 第一步：连接跳板机

```bash
ssh boyuan.zhang@login.dix.polytechnique.fr
```

输入密码登录。

---

## 第二步：安装工具（首次连接时）

### 安装Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

### 安装Zokrates

```bash
curl -LSfs get.zokrat.es | sh
source ~/.bashrc
```

### 验证安装

```bash
forge --version
zokrates --version
cast --version
```

---

## 第三步：上传项目

在**本地Windows PowerShell**执行：

```powershell
scp -r d:\antiGravity_workspace\etherum boyuan.zhang@login.dix.polytechnique.fr:~/
```

---

## 第四步：测试以太坊连接

回到**跳板机SSH会话**：

```bash
export RPC_URL="http://129.104.49.37:8545"

# 测试1: 查看区块号
cast block-number --rpc-url $RPC_URL

# 测试2: 查看最新区块
cast block --rpc-url $RPC_URL

# 测试3: 查看账户余额
cast balance 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504 --rpc-url $RPC_URL
```

**预期**：能看到区块号（数字）、区块详情、账户余额（很大的数字）

---

## 第五步：生成秘密S并测试ZK

```bash
cd ~/etherum/zokrates

# 生成随机秘密
SECRET=$(cast keccak "$(openssl rand -hex 32)")
echo "Your SECRET: $SECRET"

# 编辑Makefile
sed -i "s/SECRET = CHANGE_ME/SECRET = $SECRET/" Makefile

# 测试计算哈希
make compute
```

**预期输出**：
```
Compiling...
Computing witness...
Result:
["addr", "h", "hsa", "s"]
```

继续生成验证器：

```bash
make verify
ls -lh verifier.sol proving.key
```

**预期**：看到两个文件生成

---

## 第六步：部署合约

```bash
cd ~/etherum

# 复制verifier
cp zokrates/verifier.sol contracts/

# 设置环境变量
export RPC_URL="http://129.104.49.37:8545"
export priv1=0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e

# 编译
forge build
```

**预期**：`Compiler run successful!`

部署Verifier：

```bash
forge create contracts/verifier.sol:Verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL
```

记录输出的地址：
```bash
export verifier=0x...  # 替换为实际地址
```

部署AccessAddr：

```bash
forge create contracts/AccessAddr.sol:AccessAddr \
  --constructor-args $verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL
```

记录输出的地址：
```bash
export access=0x...  # 替换为实际地址
```

---

## 第七步：测试合约

```bash
# 测试1: 检查合约存在
cast code $access --rpc-url $RPC_URL | head -c 100

# 测试2: 查询totalAccesses
cast call $access "totalAccesses()(uint256)" --rpc-url $RPC_URL

# 测试3: 查询verifier地址
cast call $access "verifier()(address)" --rpc-url $RPC_URL

# 测试4: 查询账户余额（访问记录）
cast call $access "getBalance(address)(uint256)" 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504 --rpc-url $RPC_URL
```

**预期**：
- 测试1: 显示合约字节码
- 测试2: 返回 `0`
- 测试3: 返回你的verifier地址
- 测试4: 返回 `0`

---

## 测试成功标准

✅ 所有cast命令都有输出  
✅ forge build成功  
✅ 两个合约都成功部署  
✅ 合约查询返回预期值  

---

## 保存信息

```bash
echo "Verifier: $verifier" > deployment_info.txt
echo "AccessAddr: $access" >> deployment_info.txt
echo "SECRET: $SECRET" >> deployment_info.txt
cat deployment_info.txt
```

将这些信息记录下来，用于提交。

---

## 如果遇到问题

**SSH连接失败**：检查校园网络，确认用户名

**RPC连接失败**：必须在跳板机内执行，不能在本地

**编译失败**：检查verifier.sol是否已复制到contracts/

**部署失败**：检查账户余额是否足够
