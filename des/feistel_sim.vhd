use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;

entity feistel_sim is
	port (
		e_out: out w48;
		s_out: out w32;
		p_out: out w32
	     );
end entity feistel_sim;

architecture sim of feistel_sim is

	signal clk:  std_ulogic;
	signal s_in: w48;
	signal e_in: w32;
	signal p_in: w32;

begin

	-- the clock
	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			e_out <= e(e_in);
			p_out <= p(p_in);
			s_out <= s(s_in);
		end if;
	end process;
	
	process
	begin
		p_in <= (others => '0');
		s_in <= (others => '0');
		-- Expected : 11101111101001110010110001001101
		e_in <= (others => '0');
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		p_in <= "11110000111100001111000011110000";
		-- Expected : 11011000011010100111100001111000
		e_in <= "11110000111100001111000011110000";
		-- Expected : 100001011110100001011110100001011110100001011110
		s_in <= "101001001001101001001001101001001001101001001001";
		-- In : 101001 001001 101001 001001 101001 001001 101001 001001
		-- Got :  0100   1111   0110   0110   0001   0111   0001   1010
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
	
end architecture sim;
