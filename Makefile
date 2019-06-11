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

# Entity to compile
ENTITY = des_axi_sim
TARGET_FILE = CRACKER_$(ENTITY)

##############
# Parameters #
##############
.PHONY: all clean sim

#########
# Rules #
#########
CRACKER_%.tag : $(SRCDIR)/cracker/%.vhd 
	$(VCOM) $(VCOMFLAGS) $<
	@touch $@	

DES_%.tag: $(SRCDIR)/des/%.vhd
	$(VCOM) $(VCOMFLAGS) $<
	@touch $@	

all: sim

sim: $(TARGET_FILE).tag 
	$(VXELAB) $(VXELABFLAGS) $(LIB).$(ENTITY)
	$(VSIM) $(VSIMFLAGS) $(LIB).$(ENTITY)

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
CRACKER_des_axi_sim.tag: CRACKER_des_axi.tag
CRACKER_des_axi.tag: CRACKER_des_ctrl.tag
CRACKER_des_ctrl.tag: CRACKER_cracking_machine.tag
CRACKER_cracking_machine.tag: DES_des_cst_pkg.tag DES_des_types_pkg.tag DES_des_body_pkg.tag
