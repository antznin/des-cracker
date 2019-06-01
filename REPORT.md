# DES Cracker Report

## Contributors

 * Abbé Ahmed-Khalifa
 * Antonin Godard

## Introduction

Let us first remind the objectives of the project as defined in [des_cracker.md](./des_cracker.md) :

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

## Code

Our source code is composed mainly of three parts :
 * the DES package - which is used for encryption and decryption - is composed of
	 combinatorial function, each representing a single module of the DES algorithm as
	 detailed in the [official DES whitepaper](../doc/des.pdf).
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

### DES package

### DES cracker

### Driver

## Synthesis results

## Conclusion

<!--- architectures ? -->
