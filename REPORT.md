# DES Cracker Report

The full documentation (including this report) may be found at the following link : http://studwww.eurecom.fr/~godard/.

## Contributors

 * Abbé Ahmed-Khalifa
 * Antonin Godard

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
   * a "DES cracker", which instanciates `N` cracking machines in parallel. Each of these
	   machines do the search on a particular domain (all complementary to divide the
	   searching time in N)
   * a AXI Lite wrapper, used to communicate with the Zybo board CPU (read / write
	   requests and an IRQ)
 * a driver, which is used by the CPU to communicate with our machine

## Code

### DES package

We initially of designing the DES algorithm with an entity for each element of the
algorithm. That is, for example, an entity for each permutation, the left_shift algorithm,
etc. However we realized that it wouldn't be cost-efficient in terms of electronics, and
we knew little about the VHDL langage. Thus, we quickly changed our design and we built
*functions* for each part of the algorithm, along with constants for tables.

#### Types and constants

A huge difference to our code was defining types at the top of the des package. We
defined a type for each `std_ulogic_vector` of fixed length (see [des_types_pkg.vhd], resulting in types named
`w32`, `w48`, `w64` for respectively 32, 48, and 64 bits vectors. We also defined types
for tables : `table_t`, `table64_t` and `ttable64_t` for one or two dimensional arrays
(see [des_cst_pkg.vhd]). These types allowed our code to be cleaner throughout the whole project.

We declared every table of the [DES standard] in [des_cst_pkg.vhd] using the previously mentionned types. 

#### Functions

The functions signatures are declared in [des_types_pkg.vhd] and
are coded in [des_body_pkg.vhd].

The functions are coded like in any langage. We will not go through each of them since
they respect the [DES standard], thus details may be found there.

However the VHDL langage has some syntax restrictions we needed to comply with, especially
one that is recurrent : arithmetic operations on vectors must be done with `unsigned` vectors. As result we often has to cast `std_ulogic_vector` to unsigned and then cast the `unsigned` back to `std_ulogic_vector`.

### DES cracker

#### The cracking machine

The cracking machine represents the core or the cracking process.

It is given a plaintext p and a ciphertext c and looks for the corresponding encryption key. It uses a simple state machine composed of two states :
 * FROZEN : the machine is frozen and thus does nothing and waits for `k0_mw` to be set
 * RUNNING : the machine runs, and thus computes the DES encryption of a current key (dynamic) and compares its output with p. The current key is incremented by N, a generic parameter, allowing multiples instances of this entity to search for the key.

The state machine is driven by two signals :
 * `k0_lw` : when the least significant bits of k0 are written, the machine goes from
	 FROZEN to RUNNING
 * `k0_mw` : when the most significant bits of k0 are written, the machine goes from
	 RUNNING to FROZEN

#### The controller

#### The AXI Lite wrapper

### Driver

## Synthesis results

## Conclusion

[des_cracker.md]: ./des_cracker.md
[DES standard]: ../doc/des.pdf
[des_types_pkg.vhd]: ./des/des_types_pkg.vhd
[des_cst_pkg.vhd]: ./des/des_cst_pkg
[des_types_pkg.vhd]: ./des/des_types_pkg.vhd
[des_body_pkg.vhd]: ./des/des_body_pkg.vhd
