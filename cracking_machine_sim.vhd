use std.env.all;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;

use work.des_pkg.all;

entity cracking_machine_sim is
	port (
		found: out std_ulogic; -- Set to '1' if the mach in e found the key
		k1:    out w56;
		k_req: out w56 -- Key to send in case of requests
	);
end entity cracking_machine_sim;

architecture sim of cracking_machine_sim is

	signal clk:     std_ulogic;
	signal sresetn: std_ulogic;
	signal enable:  std_ulogic; -- "Power button"
	signal p:       w64;
	signal c:       w64;
	signal k0_mw:   std_ulogic; -- MSB of k0 written
	signal k0_lw:   std_ulogic; -- LSB of k0 written
	signal k_mr:    std_ulogic; -- MSB of k read
	signal k_lr:    std_ulogic; -- LSB of k read

begin

	dut: entity work.cracking_machine(rtl)
	generic map (
		k0 => x"00000000000000"
	)
	port map (
		clk     => clk,
		sresetn => sresetn,
		enable  => enable,
		p       => p,
		c       => c,
		k1      => k1,
		found   => found,
		k0_mw   => k0_mw,
		k0_lw   => k0_lw,
		k_mr    => k_mr,
		k_lr    => k_lr,
		k_req   => k_req
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
		variable cnt:   integer := 1;
	begin
		---- Defining default values -----
		p  <= x"f0f0f0f0f0f0f0f0";
		c  <= x"0b6a2cd8d51bb869";
		k0_lw <= '0';
		k0_mw <= '0';
		k_mr  <= '0';
		k_lr  <= '0';
		-- Found key should be 

		---- RESET AND ENABLE TESTING ____
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
			if rnd < 0.1 then
				enable <= '0';
			else
				enable <= '1';
			end if;
			wait until rising_edge(clk);
		end loop;
		---- END OF TESTING --------------

		k0_mw <= '1'; -- Starting the machine 
		wait until rising_edge(clk);

		while found /= '1' loop
			k0_lw <= '0';
			k0_mw <= '0';
			k_mr  <= '0';
			k_lr  <= '0';
			uniform(seed1, seed2, rnd);
			if rnd < 0.03 then
				k_lr <= '1';
				for i in 1 to 2 loop
					wait until rising_edge(clk);
				end loop;
				k_mr <= '1';
			end if;
			wait until rising_edge(clk);
		end loop;
		-- finish;
	end process;

end architecture sim;

-- vim: set ts=4 sw=4 tw=90 noet :
