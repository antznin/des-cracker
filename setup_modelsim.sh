export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
src=$HOME/Documents/ds
sim=/tmp/$USER/project/sim
syn=/tmp/$USER/project/syn
mkdir -p $sim $syn
cp ./Makefile $sim
cd $sim
vlib work
vmap work work
