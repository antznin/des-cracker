use std.env.all;

use work.des_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;

entity extend_key_sim is
	port (
		k_extended: out w64
	     );
end entity extend_key_sim;

architecture sim of extend_key_sim is

	signal clk:  std_ulogic;
	signal k_in: w56;

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
			k_extended <= extend_key(k_in);
		end if;
	end process;
	
	process
	begin
		k_in <= (others => '1');
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
	
end architecture sim;

