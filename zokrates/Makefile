.PHONY: all verify clean help

all: verify

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

