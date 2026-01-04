# 完整测试指南

## 第一部分：本地编译测试（Windows）

### 1.1 测试Solidity编译

```powershell
cd d:\antiGravity_workspace\etherum
forge build
```

**预期输出**：编译成功，无错误

---

## 第二部分：远程SSH测试（跳板机）

### 2.1 连接到跳板机

```bash
ssh boyuan.zhang@login.dix.polytechnique.fr
```

输入密码后进入跳板机。

### 2.2 安装工具（首次）

```bash
# 安装 Foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# 安装 Zokrates
curl -LSfs get.zokrat.es | sh
source ~/.zokrates/bin/env
```

验证安装：
```bash
forge --version
zokrates --version
cast --version
```

### 2.3 上传项目

在**本地Windows**执行：
```powershell
scp -r d:\antiGravity_workspace\etherum boyuan.zhang@login.dix.polytechnique.fr:~/
```

### 2.4 测试以太坊连接

在**跳板机**执行：
```bash
export RPC_URL="http://129.104.49.37:8545"

# 测试连接
cast block-number --rpc-url $RPC_URL
cast block --rpc-url $RPC_URL

# 检查账户余额
export addr1=0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
cast balance $addr1 --rpc-url $RPC_URL
```

**预期**：能看到区块号、区块信息、账户余额

---

## 第三部分：ZK证明生成测试

### 3.1 生成秘密S

```bash
cast keccak "$(openssl rand -hex 32)"
```

**输出示例**：`0x1234567890abcdef...`

记录这个值，例如：
```bash
export SECRET="0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
```

### 3.2 编辑Makefile

```bash
cd ~/etherum/zokrates
nano Makefile
```

修改：
```makefile
SECRET = 0x1234567890abcdef...  # 你的SECRET值
```

保存：`Ctrl+O`, `Enter`, `Ctrl+X`

### 3.3 测试ZK程序编译

```bash
# 测试ComputePwdAddr
make compute
```

**预期输出**：
- 编译成功
- 显示witness值
- 看到addr、h、hsa、s的值

### 3.4 生成验证器

```bash
make verify
ls -lh
```

**预期输出**：
- `verifier.sol` 文件生成
- `proving.key` 文件生成
- `verification.key` 文件生成

### 3.5 复制验证器到contracts

```bash
cp verifier.sol ../contracts/
cd ~/etherum
```

---

## 第四部分：合约部署测试

### 4.1 编译Solidity

```bash
forge build
```

**预期**：编译成功

### 4.2 设置环境变量

```bash
export RPC_URL="http://129.104.49.37:8545"
export priv1=0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e
export addr1=0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
```

### 4.3 部署Verifier合约

```bash
forge create contracts/verifier.sol:Verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL
```

**预期输出**：
```
Deployer: 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
Deployed to: 0x...
Transaction hash: 0x...
```

记录Verifier地址：
```bash
export verifier=0x...  # 替换为实际地址
```

### 4.4 部署AccessAddr合约

```bash
forge create contracts/AccessAddr.sol:AccessAddr \
  --constructor-args $verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL
```

**预期输出**：
```
Deployer: 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
Deployed to: 0x...
Transaction hash: 0x...
```

记录AccessAddr地址：
```bash
export access=0x... # 替换为实际地址
```

---

## 第五部分：合约功能测试

### 5.1 检查合约部署

```bash
# 检查合约代码存在
cast code $verifier --rpc-url $RPC_URL
cast code $access --rpc-url $RPC_URL
```

**预期**：显示合约字节码（很长的0x...）

### 5.2 测试基本查询

```bash
# 查询总访问次数
cast call $access "totalAccesses()(uint256)" --rpc-url $RPC_URL

# 查询地址余额（访问时间戳）
cast call $access "getBalance(address)(uint256)" $addr1 --rpc-url $RPC_URL
```

**预期**：
- totalAccesses: `0`（初始）
- getBalance: `0`（未访问）

### 5.3 测试地址转换函数

```bash
cast call $access "addressToBytes(address)(uint32[8])" $addr1 --rpc-url $RPC_URL
```

**预期**：返回8个uint32值（地址的字节表示）

### 5.4 测试地址比较函数

需要构造uint[24]输入，这比较复杂，简化测试：

```bash
# 检查verifier地址是否正确设置
cast call $access "verifier()(address)" --rpc-url $RPC_URL
```

**预期**：返回之前部署的verifier地址

---

## 第六部分：完整访问流程测试（可选高级）

### 6.1 生成完整证明

这需要从ComputePwdAddr的输出创建VerifyPwdAddr的输入，然后生成proof。这部分较复杂，基本测试可以跳过。

如果要完整测试：
1. 运行 `make compute` 并记录输出的addr、h、hsa值
2. 创建输入文件给VerifyPwdAddr
3. 生成proof.json
4. 调用accessAddr函数

---

## 测试检查清单

- [ ] 本地Foundry编译成功
- [ ] SSH连接成功
- [ ] 以太坊节点可访问
- [ ] Zokrates安装成功
- [ ] make compute成功
- [ ] make verify生成verifier.sol
- [ ] Verifier合约部署成功
- [ ] AccessAddr合约部署成功
- [ ] 合约查询函数正常工作
- [ ] 记录了Verifier地址
- [ ] 记录了AccessAddr地址
- [ ] 记录了SECRET值

---

## 故障排查

**问题1**：SSH连接失败
- 检查网络连接
- 确认用户名和密码正确

**问题2**：RPC节点无法访问
- 确认在跳板机内执行命令
- 检查RPC_URL是否正确

**问题3**：Zokrates编译失败
- 检查SECRET格式（必须是32字节，64个十六进制字符）
- 检查ADDR格式（20字节，40个十六进制字符）

**问题4**：合约部署gas不足
- 检查账户余额：`cast balance $addr1 --rpc-url $RPC_URL`
- 账户应该有足够的ETH

**问题5**：verifier.sol未生成
- 确认make verify执行无错误
- 检查当前目录是否在zokrates/

---

## 下一步

完成所有测试后，准备提交材料：
1. AccessAddr合约地址
2. SECRET值
3. `VerifyPwdAddr.zok`文件
4. `proving.key`文件
