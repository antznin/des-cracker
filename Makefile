#############
# Variables #
#############

## TO MODIFY ##
# The source directory of the project
SRCDIR = /homes/godard/Documents/ds/project
# Name of the library
LIB = work
# Variable used to choose between Xilixinx Vivado (V) or Modelsim (M)
TOOL = M
# Entity to compile
# This supposes the entity has the same name as the file
ENTITY = des_axi_sim
# The TARGET_FILE is a tag file name (without the trailing .tag). This is the file name
# which is gonna be the top entity to compile and optionnally simulate. By default the
# simulation runs.
TARGET_FILE = CRACKER_$(ENTITY)
# Your username
USER = godard
###############

# Vivado variables
VCOM = xvhdl
VCOMFLAGS = --2008 --work $(LIB)
VXELAB = xelab
VXELABFLAGS = --debug all
VSIM = xsim
VSIMFLAGS = --gui

# Modelsim variables
MCOM = vcom
MCOMFLAGS = -2008 -work $(LIB)
MSIM = vsim
MSIMFLAGS = 

# Desired compiler
COMP = $($(TOOL)COM)
COMPFLAGS = $($(TOOL)COMFLAGS)

##############
# Parameters #
##############
.PHONY: all clean sim

#########
# Rules #
#########

# cracker directory rule
CRACKER_%.tag : $(SRCDIR)/cracker/%.vhd 
	$(COMP) $(COMPFLAGS) $<
	@touch $@	

# des directory rule
DES_%.tag: $(SRCDIR)/des/%.vhd
	$(COMP) $(COMPFLAGS) $<
	@touch $@	

all: sim

sim: sim_$(TOOL)

# Simulation for Vivado
sim_V: $(TARGET_FILE).tag 
	$(VXELAB) $(VXELABFLAGS) $(LIB).$(ENTITY)
	$(VSIM) $(VSIMFLAGS) $(LIB).$(ENTITY)

# Simulation for Modelsim
sim_M: $(TARGET_FILE).tag 
	$(MSIM) $(MSIMFLAGS) $(LIB).$(ENTITY)

# run make comp for Compilation only. No simulation.
comp: $(TARGET_FILE).tag

# Build documentation
doc:
	doxygen cracker_doc.conf

# Send documentation your Eurecom personal website
send_doc:
	scp -r /tmp/doxygen/html/* $(USER)@ssh.eurecom.fr:~/htdocs/

# Clean the working directory
clean:
	rm -r *.tag

################
# Dependencies #
################
CRACKER_des_axi_sim.tag: CRACKER_des_axi.tag
CRACKER_des_axi.tag: CRACKER_des_ctrl.tag
CRACKER_des_ctrl.tag: CRACKER_cracking_machine.tag
CRACKER_cracking_machine.tag: DES_des_cst_pkg.tag DES_des_types_pkg.tag DES_des_body_pkg.tag
