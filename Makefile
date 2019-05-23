SRCDIR = /home/antograb/Documents/EURECOM/S2/DS/ds/project/des
VCOM = xvhdl
VCOMFLAGS = --2008 --work work

.PHONY: all

all: des_sim.tag

%.tag: $(SRCDIR)/%.vhd 
	$(VCOM) $(VCOMFLAGS) $<
	touch $@	

des_sim.tag: des_cst.vhd des_body.vhd des_types.vhd
