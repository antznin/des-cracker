#############
# Variables #
#############

## TO MODIFY ##
SRCDIR = /homes/godard/Documents/ds/project
LIB = work
# Here choose between Vivado (V) or Modelsim (M)
TOOL = M
# Entity to compile
ENTITY = des_axi_sim
TARGET_FILE = CRACKER_$(ENTITY)
###############

# Vivado
VCOM = xvhdl
VCOMFLAGS = --2008 --work $(LIB)
VXELAB = xelab
VXELABFLAGS = --debug all
VSIM = xsim
VSIMFLAGS = --gui
USER = godard

# Modelsim
MCOM = vcom
MCOMFLAGS = -2008 -work $(LIB)
MSIM = vsim
MSIMFLAGS = 

COMP = $($(TOOL)COM)
COMPFLAGS = $($(TOOL)COMFLAGS)

##############
# Parameters #
##############
.PHONY: all clean sim

#########
# Rules #
#########
CRACKER_%.tag : $(SRCDIR)/cracker/%.vhd 
	$(COMP) $(COMPFLAGS) $<
	@touch $@	

DES_%.tag: $(SRCDIR)/des/%.vhd
	$(COMP) $(COMPFLAGS) $<
	@touch $@	

all: sim

sim: sim_$(TOOL)

sim_V: $(TARGET_FILE).tag 
	$(VXELAB) $(VXELABFLAGS) $(LIB).$(ENTITY)
	$(VSIM) $(VSIMFLAGS) $(LIB).$(ENTITY)

sim_M: $(TARGET_FILE).tag 
	$(MSIM) $(MSIMFLAGS) $(LIB).$(ENTITY)

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
