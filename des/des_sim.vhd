use std.env.all;

use work.des_pkg.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;

entity des_sim is
	port (
		des_out_true:   out w64; -- Ciphertext
		des_out_false:  out w64 -- Ciphertext
	     );
end entity des_sim;


architecture sim of des_sim is

	signal clk:     std_ulogic;
	signal k:       w64;
	signal des_in:  w64; -- Plaintext

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
			des_out_true  <= des(des_in, k, true);
			des_out_false <= des(des_out_true, k, false);
		end if;
	end process;
	
	process
	begin
		des_in <= (others => '0');
		k      <= (others => '0');
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		des_in <= x"8787878787878787";
		k      <= x"0E329232EA6D0D73";
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		k      <= x"0000000000000001";
		des_in <= x"F0F0F0F0F0F0F0F0";
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
	
end architecture sim;
