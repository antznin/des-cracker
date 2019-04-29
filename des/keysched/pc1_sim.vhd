use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pc1_sim is
	port (
		out1: out std_ulogic_vector(27 downto 0);
		out2: out std_ulogic_vector(27 downto 0)
	     );
end entity pc1_sim;

architecture sim of pc1_sim is

	signal clk: std_ulogic;
	signal sresetn: std_ulogic;
	signal input: std_ulogic_vector(63 downto 0);
	signal power: std_ulogic;

begin

	pc: entity work.pc1(rtl)
	port map (
       		clk      => clk,
		sresetn  => sresetn,
		pc1_in   => input,
		pc1_out1 => out1,
		pc1_out2 => out2,
		power    => power
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
		input <= (others => '0');
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
		-- testing power and reset
		for i in 1 to 1000 loop
			input <= (others => '1');
			uniform(seed1, seed2, rnd);
			if rnd < 0.1 then
				sresetn <= '0';
			else
				sresetn <= '1';
			end if;
			uniform(seed1, seed2, rnd);
			if rnd < 0.1 then
				power <= '0';
			else
				power <= '1';
			end if;
			wait until rising_edge(clk);
		end loop;
		-- testing values
		input <=
	       	"1111000011110000111100001111000011110000111100001111000011110000";
		-- Expected output :
		-- 0000000000000000000000000000
		-- 1111111111111111111111110000
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		input <=
	       	"1111111111111111111111111111111100000000000000000000000000000000";
		-- Expected output :
		-- 1111000011110000111100001111
		-- 1111000011110000111100000000
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
	
end architecture sim;
