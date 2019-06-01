#############
# Variables #
#############
SRCDIR = /home/antograb/Documents/EURECOM/S2/DS/ds/project
LIB = work
VCOM = xvhdl
VCOMFLAGS = --2008 --work $(LIB)
VXELAB = xelab
VXELABFLAGS = --debug all
VSIM = xsim
VSIMFLAGS = --gui

# File to compile (without .tag)
TARGET_FILE = des_axi_sim

##############
# Parameters #
##############
.PHONY: all clean sim

#########
# Rules #
#########
%.tag : $(SRCDIR)/%.vhd 
	$(VCOM) $(VCOMFLAGS) $<
	@touch $@	

DES_%.tag: $(SRCDIR)/des/%.vhd
	$(VCOM) $(VCOMFLAGS) $<
	@touch $@	

all: sim

sim: $(TARGET_FILE).tag 
	$(VXELAB) $(VXELABFLAGS) $(LIB).$(TARGET_FILE)
	$(VSIM) $(VSIMFLAGS) $(LIB).$(TARGET_FILE)

comp: $(TARGET_FILE).tag

doc:
	doxygen cracker_doc.conf

send_doc:
	scp -r /tmp/doxygen/html/* $(USER)@ssh.eurecom.fr:~/htdocs/

clean:
	rm -r *.tag

################
# Dependencies #
################
des_axi_sim.tag: des_axi.tag
des_axi.tag: des_cracker.tag
des_cracker.tag: cracking_machine.tag
cracking_machine.tag: DES_des_cst_pkg.tag DES_des_types_pkg.tag DES_des_body_pkg.tag
