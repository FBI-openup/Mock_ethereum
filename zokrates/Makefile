ADDR = 0xfFAebd194b3F1e0989f22BaAb130F9C4D7236504
SECRET = CHANGE_ME

.PHONY: all compute verify clean help

all: verify

compute:
	zokrates compile -i ComputePwdAddr.zok -o compute.out
	zokrates compute-witness -i compute.out -a $(ADDR) $(SECRET) --verbose
	zokrates inspect -a witness

verify:
	zokrates compile -i VerifyPwdAddr.zok -o verify.out
	zokrates setup -i verify.out
	zokrates export-verifier

clean:
	rm -f *.out witness proof.json verification.key proving.key verifier.sol abi.json

help:
	@echo "Usage:"
	@echo "  make compute  - Generate hash with ComputePwdAddr"
	@echo "  make verify   - Compile VerifyPwdAddr and export Solidity verifier"
	@echo "  make clean    - Remove generated files"
	@echo ""
	@echo "Generate SECRET with: cast keccak <random_value>"

