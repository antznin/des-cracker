library ieee;
use ieee.std_logic_1164.all;
--use des_types_pkg.all;

package des_cst is

-- Unconstrained array
	type table_t is array(natural range <>) of natural;

	-- IP & IIP constants

	constant ip_table : table_t(64 downto 1) :=
		 (58,50,42,34,26,18,10,2,
		 60,52,44,36,28,20,12,4,
		 62,54,46,38,30,22,14,6,
		 64,56,48,40,32,24,16,8,
		 57,49,41,33,25,17,9,1,
		 59,51,43,35,27,19,11,3,
		 61,53,45,37,29,21,13,5,
		 63,55,47,39,31,23,15,7);


       	constant iip_table : table_t(64 downto 1) :=
		 (40,8,48,16,56,24,64,32,
		 39,7,47,15,55,23,63,31,
		 38,6,46,14,54,22,62,30,
		 37,5,45,13,53,21,61,29,
		 36,4,44,12,52,20,60,28,
		 35,3,43,11,51,19,59,27,
		 34,2,42,10,50,18,58,26,
		 33,1,41,9,49,17,57,25);

	-- Feistel constants
	constant p_table: table_t(32 downto 1) := 
		(16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10, 2, 8, 24,
		14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25);

        -- KS constants
--	constant pc1_table: table_t(32 downto 1) := ;
--	constant pc1_table: table_t(32 downto 1) := ;
		

	
end package des_cst;
