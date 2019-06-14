# DES Cracker Report

The full documentation (including this report) may be found at the following link : http://studwww.eurecom.fr/~godard/.

## Contributors

 * Abbe Ahmed-Khalifa, ahmeda@eurecom.fr
 * Antonin Godard, godard@eurecom.fr

## Introduction

Let us first remind the objectives of the project as defined in [des_cracker.md] :

> This project aims at estimating as accurately as possible the time it would take to
> crack the DES (Data Encryption Standard) encryption algorithm using Zybo boards. You
> will design a hardware DES encryption engine, code it in VHDL, validate it and
> synthesize it for the FPGA part of the zynq core of your Zybo board. Based on the
> performance results that you will get (resources usage and maximum reachable clock
> frequency), you will then design a cracking machine by instantiating as many DES
> encryption engines as you can and by distributing the computation effort among them.
>
> The cracking machine will be given a plaintext $`P`$, a ciphertext $`C`$, 64 bits each,
> and a 56-bits starting secret key $`K_0`$. It will try to encrypt $`P`$ with all
> possible 56-bits keys $`K\ge K_0`$ until the result equals $`C`$. When the match will
> have been found the cracking machine will store the corresponding secret key $`K_1`$ in
> a register and raise an interrupt to inform the software stack that runs on the ARM CPU
> of the Zynq core.
>
> The cracking machine will communicate with the CPU using the AXI4 lite interface.

Our source code is composed mainly of three parts :
 * the DES package - which is used for encryption and decryption - is composed of
	 combinatorial functions and constants, each representing a single module of the DES algorithm as
	 detailed in the [DES standard].
 * the cracker itself, represented in a hierarchical manner, that is from bottom level
     to top level :
   * a cracking machine, used only to do a search of the private key. It uses the `des`
	   function of the DES package
   * a DES controller, which instanciates `N` cracking machines in parallel. Each of these
	   machines do the search on a particular domain (all complementary to divide the
	   searching time by N)
   * a AXI Lite wrapper, used to communicate with the Zybo board CPU (read / write
	   requests and an IRQ)
 * a driver, which is used by the CPU to communicate with our machine

## Code

### DES package

We initially thought of designing the DES algorithm with an entity for each element of the
algorithm. That is, for example, an entity for each permutation, the left_shift algorithm,
etc. However we realized that it wouldn't be cost-efficient in terms of electronics, and
we knew little about the VHDL language. Thus, we quickly changed our design and we built
*functions* for each part of the algorithm, along with *constants* for tables.

#### Types and constants

A huge difference to our code was defining types at the top of the des package. We
defined a type for each `std_ulogic_vector` of fixed length (see [des_types_pkg.vhd]), resulting in types named
`w32`, `w48`, `w64` for respectively 32, 48, and 64 bits vectors. We also defined types
for tables : `table_t`, `table64_t` and `ttable64_t` for one or two dimensional arrays
(see [des_cst_pkg.vhd]). These types allowed our code to be cleaner throughout the whole project.

We declared every table of the [DES standard] in [des_cst_pkg.vhd] using the previously mentionned types.

#### Functions

The functions signatures are declared in [des_types_pkg.vhd] and
are coded in [des_body_pkg.vhd].

The functions are coded like in any language. We will not go through each of them since
they respect the [DES standard], thus details may be found there.

However the VHDL language has some syntax restrictions we needed to comply with, especially
one that is recurrent : arithmetic operations on vectors must be done with `unsigned` vectors.
As result we often have to cast `std_ulogic_vector` to unsigned and then cast the `unsigned`
back to `std_ulogic_vector`.

##### Simulations

Finally, we have simulated our functions to check if they work well. To do so, we made different tests :
 * for the permutations functions IP and IIP, we use as the input of IIP the output of IP
   after these permutations the output should be identical to the initial input only if the functions work.
 * for the shift function, we just compare our input and our output to see if it has been well shifted

### DES cracker

#### The cracking machine

The cracking machine represents the core or the cracking process.

It is given a plaintext p and a ciphertext c and looks for the corresponding encryption key.
It uses a simple state machine composed of two states :
 * `FROZEN` : the machine is frozen and thus does nothing and waits for `k0_mw` to be set
 * `RUNNING` : the machine runs, and thus computes the DES encryption of a current key (dynamic)
   and compares its output with p. The current key is incremented by N, a generic parameter,
   allowing multiples instances of this entity to search for the key.

The state machine is driven by two signals :
 * `k0_lw` : when the least significant bits of `k0` are written, the machine goes from
	 `FROZEN` to `RUNNING`
 * `k0_mw` : when the most significant bits of `k0` are written, the machine goes from
	 `RUNNING` to `FROZEN`

Our choice of design is to do one full encipher per clock cycle.

##### Simulation

Every input and outputs are respectively mapped to internal signals (to be driven) and
outputs (to be observed).

The simulation has a simple clock process for simulating a clock.

A process is in charge of simulating the behavior of the machine itself. This is what it
does step by step :
 1. Initialize the inputs (such as `p`, `c`, `starting_k`, etc) to known values so that we
	can verify the outputs with pre-known values
 1. We test the response behavior when setting `sresetn` and `enable` to `0` (separately)
 1. We test the response behavior when setting `sresetn` and `enable` to `0` together and
	randomly. At this step we also test the behavior of the machine when setting `k0_lw`
	and `k0_mw` to `1` for one clock period. The machine should start for 10 clock cycles
	and then stop.
 1. The last step consists in searching for the key. Before doing that we reset
	everything. Then we start the machine and we do not stop the simulation until the key
	is found. When it is, the simulation stops.

#### The controller

The controller represents the interface between the AXI wrapper and the cracking machine.
It has two purposes: the controller generates N machines and sends them the starting keys.

It also allows us to read the current key requested with a simple state machine of two
states :
 * `UPDATING` : in this state the `k_req` signal is always assigned the value of
	 `current_k` at each clock cycle
 * `FREEZE` : in this state the `k_req` signal is frozen (nothing is assigned to it) and
	 waits for the transaction between the CPU and the slave to be finished

The machine is driven by two signals :
 * `k_lr` : when the least significant bits of `k` are read, the machine goes from UPDATING to FREEZE
 * `k_mr` : when the most significant bits of `k` are read, the machine goes from FREEZE to UPDATING

##### Simulation

Finally to simulate our controller, we generate seven cracking machines and map them, we
generate a clock signal and initialize the internal signals which represent the plain
text, the cyphertext, the starting key and the flags used for writting `k0` and reading `k`.

Then we have made several tests divided in two processes:
 1. In the first process :
   * we test the signal sresetn by forcing it to zero for 10 clock cycles
   * then, we test the machines by setting a value to the `k0` flags at random time thus it
     should make the state machine change its state
   * finally, we test if the cracking machines are able to find the secret key and we make the process stop
 1. concurrently in the second process :
  we design another process which will simulate the key requests. It will requests
  periodically the last of the computed keys as we would do to track the progress of the cracking


#### The AXI Lite wrapper

The purpose of the AXI Lite Wrapper is to enable the CPU to communicate with the cracker.
It instanciates and maps one controller. Furthermore, it has three main purposes : it handles the IRQ request,
it uses two state machines; one for the write requests and another one for the read requests.

The first state machine used for the write requests is composed of two states :
 * when the slave is ready, the machine goes from `waiting` to `running`
 * when the data and the write address have been considered as valid, the CPU writes
   into the slave and the machine goes from `running` to `waiting`

The second one used for read requests also is composed of two states :
 * when the slave is ready, the machine goes from `waiting` to `running`
 * when the read address has been considered as valid, the CPU reads
   the data in the slave and the machine goes from `running` to `waiting`

##### The simulation

Finally, to simulate our AXI we will use two processes : one for generating the clock signal and another one to test our instanciation of our entity.  
Here below is the description of the tests of the second process:   
 1. first, we write our plaintext and ciphertext then we read their values
 1. we write the starting key and we read its value after that to be sure
 1. then as the cracking machines start running after writing the starting key, we check the current key continuously until it finds the secret key
 1. when the while loop stops and the secret key is found, we make a last read request to get the value of the secret key


### Driver

To this date the driver hasn't been finished.

We also encountered a bug when writing into the `k0` address space : it crashes the OS.

## Synthesis results

The [synthesis script] was based off another project and was adapted to our project.

The synthesis allowed us to get timing and utilization reports for our project. Since the
goal is to optimize the cracker to find the key as fast as possible, we varied the number
of machines and the clock frequency so that the utilization and timing were maxed out.

Thanks to our modular design of the controller, we were able to make the number of
machines vary one by one.

The final results led to these parameters :
 * `N` = 12 : 12 machines can run in parallel without using all the available space. By
 	looking at the utilization report we use around 98% of the card ;
 * `frequency_mhz` = 20.7 : the maximum frequency we can get is 20.7 MHz. With this
 	parameter we got a Worst Negative Slack of 0.1

## Conclusion

Our choice of architecture was to do a full encryption per clock cycles. It has been revealed
thanks to other groups doing the same project that this may not be the best approach. We
could have done two things to improve our cracker :
 * optimize the functions and the register usage in our code to instanciate more machines
	 and thus find the key faster
 * change the architecture to a pipeline architecture. That is not computing a full
	 encryption per clock cycle but rather computing one or more round of the DES
	 algorithm at each clock cycle. That would have allowed us to increase the clock
	 frequency of our design without adding too much board utilization

[des_cracker.md]: ./des_cracker.md
[DES standard]: ../doc/des.pdf
[des_types_pkg.vhd]: ./des/des_types_pkg.vhd
[des_cst_pkg.vhd]: ./des/des_cst_pkg
[des_types_pkg.vhd]: ./des/des_types_pkg.vhd
[des_body_pkg.vhd]: ./des/des_body_pkg.vhd
[synthesis script]: ./des_cracker_axi_wrapper.syn.tcl
