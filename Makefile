VERILATOR = verilator


BUILD = build
SIM_FILE = out
SIM_BIN = $(BUILD)/$(SIM_FILE)

$(BUILD)/%: %.sv $(wildcard *.sv)
	$(VERILATOR) \
		-j 0 --binary --trace --timing  \
    -Mdir $(BUILD) \
		--top-module $* \
		-o $* \
		conf.vlt\
		fpu/adder/adder.v \
		$^

$(BUILD)/%.vcd: $(BUILD)/%
	$<
	mv trace.vcd $@

vis_%: $(BUILD)/%.vcd
	gtkwave $<

testgen: 
	python gen_test.py

clean:
	rm -rf $(BUILD)

.PHONY: clean testgen
