SRCDIR = /home/antograb/Documents/EURECOM/S2/DS/ds/project
VCOM = xvhdl
VCOMFLAGS = --2008 --work work

.PHONY: all clean
.NOTPARALLEL:

%.tag : $(SRCDIR)/%.vhd 
	$(VCOM) $(VCOMFLAGS) $<
	touch $@	

DES_%.tag: $(SRCDIR)/des/%.vhd
	$(VCOM) $(VCOMFLAGS) $<
	touch $@	

all: des_axi_sim.tag

des_axi_sim.tag: des_axi.tag
des_axi.tag: des_cracker.tag
des_cracker.tag: cracking_machine.tag
cracking_machine.tag: DES_des_cst_pkg.tag DES_des_types_pkg.tag DES_des_body_pkg.tag

clean:
	rm -r *.tag
