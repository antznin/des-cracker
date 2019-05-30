library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

package des_pkg is

	subtype w4  is std_ulogic_vector (1 to 4 );
	subtype w6  is std_ulogic_vector (1 to 6 );
	subtype w28 is std_ulogic_vector (1 to 28);
	subtype w32 is std_ulogic_vector (1 to 32);
	subtype w48 is std_ulogic_vector (1 to 48);
	subtype w56 is std_ulogic_vector (1 to 56);
	subtype w64 is std_ulogic_vector (1 to 64);

	type rkey_table is array(1 to 16) of w48;
	type table56 is array(natural range <>) of std_ulogic_vector(1 to 56);
	type table112 is array(natural range <>) of std_ulogic_vector(1 to 112);
	type table_bit is array(natural range <>) of std_ulogic;
	type table_u56 is array(natural range<>) of unsigned(1 to 56);

	-- Initial and final permutations
	function ip(w : w64)            return w64;
	function iip(w1 : w32;w2 : w32) return w64;

	---- Feistel function
	function p(w : w32)           return w32;
	function s(w : w48)           return w32;
	function e(w : w32)           return w48;
	function f(r : w32; rk : w48) return w32;
	
	---- Key schedule
	function extend_key(k_in: w56)                  return w64; 
	function left_shift(w : w28; amount : natural)  return w28;
	function right_shift(w : w28; amount : natural) return w28;
	function pc1(w : w64)                           return w56;
	function pc2(w1 : w28; w2 : w28)                return w48;
	function ks(k: w64)                             return rkey_table;

	---- Main function
	function des (p : w64; k : w64; encipher: boolean) return w64;

	---- Key generator function
	function inc(k : w56; N : integer) return w56;


end package des_pkg;

-- vim: set ts=4 sw=4 tw=90 noet :
