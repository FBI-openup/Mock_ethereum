# 手动测试完整流程

由于SSH密钥有密码保护，请在**PowerShell**中手动执行以下步骤。

---

## 第一步：上传项目到跳板机

```powershell
scp -r d:\antiGravity_workspace\etherum boyuan.zhang@login.dix.polytechnique.fr:~/
```

输入SSH密钥的passphrase（或学校密码）。

**预期**：文件上传成功，显示进度条。

---

## 第二步：连接到跳板机

```powershell
ssh boyuan.zhang@login.dix.polytechnique.fr
```

输入passphrase后，你会看到跳板机的提示符。

---

## 第三步：检查工具是否已安装

```bash
forge --version
zokrates --version
cast --version
```

**如果显示 "command not found"**，执行安装命令：

```bash
# 安装Foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup

# 安装Zokrates
curl -LSfs get.zokrat.es | sh
source ~/.bashrc

# 验证安装
forge --version
zokrates --version
```

---

## 第四步：测试以太坊连接

```bash
export RPC_URL="http://129.104.49.37:8545"

# 测试1: 查看区块号
cast block-number --rpc-url $RPC_URL

# 测试2: 查看账户余额
cast balance 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504 --rpc-url $RPC_URL
```

**预期**：
- 区块号：一个数字（例如 123456）
- 余额：一个很大的数字（表示Wei单位）

---

## 第五步：运行自动化测试脚本

```bash
cd ~/etherum
chmod +x test_all.sh
./test_all.sh
```

**脚本会自动执行**：
1. ✓ 测试RPC连接
2. ✓ 生成随机秘密S
3. ✓ 编译ZK程序（make compute）
4. ✓ 生成验证器（make verify）
5. ✓ 编译Solidity（forge build）
6. ✓ 部署Verifier合约
7. ✓ 部署AccessAddr合约
8. ✓ 测试合约函数
9. ✓ 保存部署信息到deployment_info.txt

**预期输出最后会显示**：
```
=========================================
ALL TESTS PASSED!
=========================================

Deployment Info:
Verifier:   0x...
AccessAddr: 0x...
SECRET:     0x...
```

---

## 第六步：查看部署信息

```bash
cat deployment_info.txt
```

**记录这三个值**，用于提交：
- Verifier地址
- AccessAddr地址
- SECRET值

---

## 第七步：手动验证（可选）

如果想手动测试每一步：

### 7.1 生成SECRET
```bash
SECRET=$(cast keccak "$(openssl rand -hex 32)")
echo "SECRET: $SECRET"
```

### 7.2 测试ZK编译
```bash
cd ~/etherum/zokrates
sed -i "s/SECRET = CHANGE_ME/SECRET = $SECRET/" Makefile
make compute
make verify
```

### 7.3 部署合约
```bash
cd ~/etherum
cp zokrates/verifier.sol contracts/
forge build

export RPC_URL="http://129.104.49.37:8545"
export priv1=0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e

forge create contracts/verifier.sol:Verifier \
  --broadcast \
  --private-key $priv1 \
  --rpc-url $RPC_URL
```

记录Verifier地址：
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

记录AccessAddr地址：
```bash
export access=0x...  # 替换为实际地址
```

### 7.4 测试合约
```bash
# 查询totalAccesses
cast call $access "totalAccesses()(uint256)" --rpc-url $RPC_URL

# 查询verifier地址
cast call $access "verifier()(address)" --rpc-url $RPC_URL
```

---

## 常见错误处理

**错误1**: `forge: command not found`
- 执行第三步的安装命令
- 执行 `source ~/.bashrc`

**错误2**: `RPC connection failed`
- 确认在跳板机内执行（不是本地）
- 检查RPC_URL是否正确设置

**错误3**: `make: command not found`
- 安装make：`sudo apt install make`（可能需要管理员权限）

**错误4**: 部署失败
- 检查账户余额是否足够
- 检查verifier.sol是否已复制到contracts/

---

## 测试成功的标志

✅ cast命令能查询区块  
✅ make compute成功  
✅ make verify生成verifier.sol  
✅ forge build成功  
✅ 两个合约都部署成功  
✅ cast call能查询合约  
✅ deployment_info.txt包含三个地址  

---

## 下一步

测试成功后，准备提交材料：
1. AccessAddr合约地址
2. SECRET值
3. `zokrates/VerifyPwdAddr.zok` 文件
4. `zokrates/proving.key` 文件

从跳板机下载文件到本地：

```powershell
# 在本地PowerShell执行
scp boyuan.zhang@login.dix.polytechnique.fr:~/etherum/deployment_info.txt .
scp boyuan.zhang@login.dix.polytechnique.fr:~/etherum/zokrates/VerifyPwdAddr.zok .
scp boyuan.zhang@login.dix.polytechnique.fr:~/etherum/zokrates/proving.key .
```
