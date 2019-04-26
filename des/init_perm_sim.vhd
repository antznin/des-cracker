use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity initperm_sim is
	port ( output: out std_ulogic_vector(63 downto 0) );
end entity initperm_sim;

architecture sim of initperm_sim is

	signal clk: std_ulogic;
	signal sresetn: std_ulogic;
	signal input: std_ulogic_vector(63 downto 0);
	signal power: std_ulogic;

begin

	perm: entity work.initp(rtl)
	port map (
       		clk => clk,
		sresetn => sresetn,
		input => input,
		output => output,
		power => power
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
	begin
		sresetn <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
		for i in 1 to 1000 loop
			uniform(seed1, seed2, rnd);
			if rnd < 0.1 then
				sresetn <= '0';
			else
				sresetn <= '1';
			end if;
			uniform(seed1, seed2, rnd);
			if rnd < 0.2 then
				power <= '0';
			else
				power <= '1';
			end if;
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
	
	-- drive the input
	process 
	begin
		input <= (others => '0');
		for i in 1 to 1000 loop
			for i in 1 to 10 loop
				wait until rising_edge(clk);
			end loop;
			input <= std_ulogic_vector(unsigned(input) + 2000000000);
		end loop;
	end process;
end architecture sim;
