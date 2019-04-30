-- This simulation tests the two permutations. Since the second is the inverse of the 
-- first, it drives the output of the first into the second. Thus you can easily compare
-- the values.

use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity initperm_sim is
	port ( output_inv: out std_ulogic_vector(63 downto 0) );
end entity initperm_sim;

architecture sim of initperm_sim is

	signal clk:        std_ulogic;
	signal sresetn:    std_ulogic;
	signal input:      std_ulogic_vector(63 downto 0);
	signal output:     std_ulogic_vector(63 downto 0);
	signal power:      std_ulogic;

begin

	perm: entity work.initp(rtl)
	port map (
       		clk     => clk,
		sresetn => sresetn,
		input   => input,
		output  => output,
		power   => power
	);	
	perm_inv: entity work.inv_initp(rtl)
	port map (
       		clk     => clk,
		sresetn => sresetn,
		input   => output,
		output  => output_inv,
		power   => power
	);	

	-- the clock
	process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;

	process
		variable seed1: positive := 1;
		variable seed2: positive := 1;
		variable rnd:   real;
		variable init:  std_ulogic := '0';
	begin
		input <= (others => '0');
		sresetn <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		power <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		power <= '1';

		while unsigned(input) /= 1000 loop -- Testing the first 1000 values
			input <= std_ulogic_vector(unsigned(input) + 1);
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
end architecture sim;
