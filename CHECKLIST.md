# 项目要求完整检查清单

## ✅ 已完成的部分

### 1. ZK程序实现 ✅

#### ComputePwdAddr.zok
- ✅ 计算 `hs = H(S)` 
- ✅ 计算 `hsa = H(S, I)` 
- ✅ 计算 `h = H(H(S), H(S,I))`
- ✅ 返回 `(addr, h, hsa, s)`

#### VerifyPwdAddr.zok
- ✅ 验证 `hsa` 正确 (assert hsa_computed == hsa)
- ✅ 验证 `h` 正确 (assert h_computed == h)
- ✅ 使用 `private u32[8] s` 作为私密输入

### 2. 智能合约实现 ✅

#### Interface.sol (内嵌在AccessAddr.sol)
- ✅ 修改为 `uint[24]` 输入（第10行）
- ✅ 原始是 `uint[8]`，现在改为适配新的哈希结构

#### AccessAddr.sol
- ✅ 继承自lab2的Access.sol
- ✅ 验证地址匹配：`compare(input, msg.sender)` (第28行)
- ✅ 验证ZK证明：`verifier.verifyTx(proof, input)` (第30行)
- ✅ 实现 `addressToBytes()` 辅助函数 (第49-58行)
- ✅ 实现 `compare()` 函数 (第39-47行)

### 3. 测试脚本 ✅

#### test_all.sh
- ✅ 测试RPC连接
- ✅ 检查账户余额
- ✅ 生成随机SECRET
- ✅ 转换地址和SECRET为u32数组
- ✅ 编译两个Zokrates程序
- ✅ 计算witness
- ✅ Setup proving scheme（生成proving.key）
- ✅ 导出verifier.sol
- ✅ 使用Forge构建
- ✅ 部署Verifier合约
- ✅ 部署AccessAddr合约
- ✅ 测试合约函数

## 📋 需要提交的材料

根据项目要求，需要发送给 `daniel.augot@inria.fr`：

### 1️⃣ 合约地址
- **来源**: 运行 `test_all.sh` 后的 `deployment_info.txt`
- **格式**: `0x...` (以太坊地址)

### 2️⃣ 密钥 S
- **来源**: 运行 `test_all.sh` 后的 `deployment_info.txt`
- **格式**: `0x...` (256位哈希)
- **生成方式**: `cast keccak "$(openssl rand -hex 32)"`

### 3️⃣ VerifyPwdAddr.zok
- **位置**: `zokrates/VerifyPwdAddr.zok`
- **作为邮件附件**

### 4️⃣ Proving key (pk)
- **位置**: `zokrates/proving.key` (SSH服务器上)
- **需要下载**: 从SSH服务器下载到本地
- **作为邮件附件**

## 🚀 完成提交的步骤

### 在SSH服务器上：

```bash
# 1. 拉取最新代码并运行测试（如果还没运行）
git reset --hard
git pull
chmod +x test_all.sh
./test_all.sh

# 2. 准备提交材料
chmod +x prepare_submission.sh
./prepare_submission.sh

# 3. 下载文件到本地
# 在本地Windows终端运行：
# scp boyuan.zhang@login.dix.polytechnique.fr:~/etherum/submission/* ./submission/
```

### 在本地：

```bash
# 或者使用你的文件管理器通过SSH挂载下载：
# ssh://login.dix.polytechnique.fr
# 然后复制 ~/etherum/submission/ 文件夹
```

## 📧 邮件模板

```
收件人: daniel.augot@inria.fr
主题: INF571 ZK Lab - Boyuan Zhang

您好，

以下是我的ZK Access Control项目提交：

合约地址: [从 deployment_info.txt 复制]
密钥 S: [从 deployment_info.txt 复制]

附件:
- VerifyPwdAddr.zok
- proving.key

学生信息:
姓名: Boyuan Zhang
邮箱: boyuan.zhang+ep@ip-paris.fr
地址: 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
私钥（如需测试）: 0x22fb47a1e41741361bbb3f60ef0489ee53d7f2ce4985c1fb4d16abfaa00e866e

谢谢！
```

## ⚠️ 注意事项

1. **proving.key 文件很重要**：这是老师验证你的实现所必需的
2. **确保文件完整**：检查 `proving.key` 文件大小不为0
3. **保存好 SECRET**：老师会用这个密钥来测试你的合约
4. **合约地址别搞错**：确认是 AccessAddr 的地址，不是 Verifier 的

## ✅ 最终检查清单

运行以下命令确认所有文件都存在：

```bash
# 在SSH服务器上
ls -lh zokrates/proving.key          # 应该看到文件大小
ls -lh zokrates/VerifyPwdAddr.zok   # 应该看到文件
cat deployment_info.txt              # 应该显示3行信息
```

---

**状态**: 所有代码实现已完成 ✅  
**待办**: 从SSH服务器下载提交材料并发送邮件
