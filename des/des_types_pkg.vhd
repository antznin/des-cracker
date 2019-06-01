library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

--! @brief This package contains all declarations of types, subtypes and functions used for a
--! DES encryption.
package des_pkg is

	-----------
	-- Types --
	-----------

	subtype w4  is std_ulogic_vector (1 to 4 ); --! Bit vector of size 4  
	subtype w6  is std_ulogic_vector (1 to 6 ); --! Bit vector of size 6  
	subtype w28 is std_ulogic_vector (1 to 28); --! Bit vector of size 28 
	subtype w32 is std_ulogic_vector (1 to 32); --! Bit vector of size 32 
	subtype w48 is std_ulogic_vector (1 to 48); --! Bit vector of size 48 
	subtype w56 is std_ulogic_vector (1 to 56); --! Bit vector of size 56 
	subtype w64 is std_ulogic_vector (1 to 64); --! Bit vector of size 64 

	type rkey_table is array(1 to 16)          of w48; --! Table used to store round keys
	type table56    is array(natural range <>) of w56; --! Table of w56 vector
	type table112   is array(natural range <>) of std_ulogic_vector(1 to 112);
	type table_bit  is array(natural range <>) of std_ulogic; --! Table of bits 
	type table_u56  is array(natural range <>) of unsigned(1 to 56); --! Table of unsigned vector of length 56

	------------------------------------
	-- Initial and final permutations --
	------------------------------------
	
	--! Initial permutation as described in the DES algorithm
	function ip(w : w64)            return w64;
	--! Inverse initial permutation (and final) as described in the DES algorithm
	function iip(w1 : w32 ; w2 : w32) return w64;

	-----------------------
	-- Feistel functions --
	-----------------------
	
	function p(w : w32)           return w32; --! Feistel permutation
	function s(w : w48)           return w32; --! Substitution boxes function
	function e(w : w32)           return w48; --! Extend Feistel function 
	function f(r : w32; rk : w48) return w32; --! Feistel main function
	
	----------------------------
	-- Key schedule functions --
	----------------------------
	
	--! Key extension function (56 to 64 bits by adding 0 every 8th bit)
	function extend_key(k_in: w56)                  return w64; 
	function left_shift(w : w28; amount : natural)  return w28; --! Left shift function of the DES algorithm
	function right_shift(w : w28; amount : natural) return w28;
	function pc1(w : w64)                           return w56; --! PC1 permutation
	function pc2(w1 : w28; w2 : w28)                return w48; --! PC2 permutation
	function ks(k: w64)                             return rkey_table; --! Key schedule main function

	-----------------------
	-- Main DES function --
	-----------------------
	
	--! DES main function. encipher is a boolean used to either encipher or decipher a 64
	--! bits text :
	--!  * `true` : encipher text
	--!  * `false` : decipher text
	--!
	--! It reverses the round keys order as described in the DES algorithm (reversible
	--! cipher).
	function des (p : w64; k : w56; encipher: boolean) return w64;

	---------------------------------
	-- Key incrementation function --
	---------------------------------
	
	--! Key increment function
	function inc(k : w56; N : integer) return w56;


end package des_pkg;

-- vim: set ts=4 sw=4 tw=90 noet :
