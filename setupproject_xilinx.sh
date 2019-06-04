export PATH=$PATH:/tools/Xilinx/Vivado/2018.3/bin:/tools/Xilinx/SDK/2018.3/bin
src=$HOME/Documents/EURECOM/S2/DS/ds
sim=/tmp/$USER/project/sim
syn=/tmp/$USER/project/syn
mkdir -p $sim $syn
mkdir $sim/work
cp ./Makefile $sim
printf "Examples:\n"
printf "Synthesis:\n\tvivado -mode batch -source $src/project/des_cracker_axi_wrapper.syn.tcl -notrace -tclargs axi\n"
