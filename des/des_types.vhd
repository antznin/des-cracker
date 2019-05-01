library ieee;
use ieee.std_logic_1164.all;

package des_pkg is

	subtype w28 is std_ulogic_vector (28 downto 1);
	subtype w32 is std_ulogic_vector (32 downto 1);
	subtype w48 is std_ulogic_vector (48 downto 1);
	subtype w56 is std_ulogic_vector (56 downto 1);
	subtype w64 is std_ulogic_vector (64 downto 1);
	

	-- Initial and final permutations
	function ip(w : w64)  return w64;
	function iip(w1 : w32;w2 : w32) return w64;


	
	-- Key schedule
	function left_shift(w : w28; amount : natural)  return w28;
	function right_shift(w : w28; amount : natural) return w28;
	function pc1(w : w56)                           return w56;
	function pc2(w1 : w28; w2 : w28)                return w48;

	-- Main function
--	 function des (p : w64; k : w56) return w64;

end package des_pkg;
