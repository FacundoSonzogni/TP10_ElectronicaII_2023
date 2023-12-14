.PHONY : all receptor_ir wav-receptor_ir 

all : receptor_ir


receptor_ir : design.vhd testbench.vhd
	ghdl -i --std=08 *.vhd
	ghdl -m --std=08 receptor_ir_tb
	ghdl -r --std=08 receptor_ir_tb

wav-receptor_ir :
	ghdl -i --std=08 *.vhd
	ghdl -m --std=08 receptor_ir_tb
	ghdl -r --std=08 receptor_ir_tb --assert-level=none --wave=receptor_ir_tb.ghw
	gtkwave -f receptor_ir_tb.ghw

clean :
	rm *.cf *.o *.exe *.ghw
