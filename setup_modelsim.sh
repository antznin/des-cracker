export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
src=$HOME/ds
sim=/tmp/ahmeda/project/sim
syn=/tmp/ahmeda/project/syn
mkdir -p $sim $syn
cp ./Makefile $sim
cd $sim
vlib work
vmap work work
