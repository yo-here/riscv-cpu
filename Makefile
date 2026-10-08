kk.PHONY: lint test

MODULES = regfile imm_gen alu decoder

lint:
	for m in $(MODULES); do verilator --lint-only -Wall --top-module $$m rtl/$$m.sv || exit 1; done

test: lint
	for m in $(MODULES); do verilator --binary --timing --Mdir sim/obj_$$m --top-module $${m}_tb rtl/$$m.sv tb/$${m}_tb.sv -o $${m}_test || exit 1; ./sim/obj_$$m/$${m}_test || exit 1; done
