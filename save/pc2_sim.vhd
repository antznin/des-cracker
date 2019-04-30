use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pc2_sim is
	port (
		out1: out std_ulogic_vector(47 downto 0)
	     );
end entity pc2_sim;

architecture sim of pc2_sim is

	signal clk:      std_ulogic;
	signal sresetn:  std_ulogic;
	signal in1:      std_ulogic_vector(27 downto 0);
	signal in2:      std_ulogic_vector(27 downto 0);
	signal power:    std_ulogic;

begin

	pc: entity work.pc2(rtl)
	port map (
       		clk      => clk,
		sresetn  => sresetn,
		pc2_in1  => in1,
		pc2_in2  => in2,
		pc2_out1 => out1,
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
		in1 <= (others => '0');
		in2 <= (others => '0');
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
		-- testing power and reset
		for i in 1 to 1000 loop
			in1 <= (others => '1');
			in2 <= (others => '1');
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
		in1 <=
	       	"1111111111111111111111111111";
		in2 <=
	       	"0000000000000000000000000000";
		-- Expected output :
		-- 000000000000000000000000111111111111111111111111
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		in1 <=
	       	"1111000011110000111100001111";
		in2 <=
	       	"1111000011110000111100001111";
		-- Expected output :
		-- 011010110001011110001101001111110101001101100011
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;
	
end architecture sim;
