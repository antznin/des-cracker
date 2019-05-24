use std.env.all;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;

use work.des_pkg.all;

entity cracking_machine_sim is
	port (
		found:   out std_ulogic; -- Set to '1' if the mach in e found the key
		found_k: out w56
	);
end entity cracking_machine_sim;

architecture sim of cracking_machine_sim is

	signal clk:        std_ulogic;
	signal sresetn:    std_ulogic;
	signal enable:     std_ulogic; -- "Power button"
	signal p:          w64;
	signal c:          w64;
	signal k0_mw:      std_ulogic; -- MSB of k0 written
	signal k0_lw:      std_ulogic; -- LSB of k0 written
	signal starting_k: w56;

begin

	cm: entity work.cracking_machine(rtl)
	generic map (
		N          => 1 -- Testing only one machine
	)
	port map (
		clk        => clk,
		sresetn    => sresetn,
		enable     => enable,
		p          => p,
		c          => c,
		found_k    => found_k,
		starting_k => starting_k,
		found      => found,
		k0_mw      => k0_mw,
		k0_lw      => k0_lw
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
		---- Defining default values -----
		p          <= x"f0f0f0f0f0f0f0f0";
		c          <= x"0b6a2cd8d51bb869";
		starting_k <= x"00000000000000";
		k0_lw      <= '0';
		k0_mw      <= '0';
		-- Found key should be 00000000000408 (56 bits)

		---- RESET AND ENABLE TESTING ____
		-- Testing sresetn
		sresetn <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
		wait until rising_edge(clk);
		-- Testing enable
		enable <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		enable <= '1';
		wait until rising_edge(clk);
		---- Testing both ----
		-- Starting the machine 
		k0_mw <= '1';
		wait until rising_edge(clk);
		k0_mw <= '0';
		wait until rising_edge(clk);
		for i in 1 to 100 loop
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
			-- Freezing the machine sometines to see if it starts back alright
			uniform(seed1, seed2, rnd);
			if rnd < 0.05 then
				k0_lw <= '1'; -- Stop
				wait until rising_edge(clk);
				k0_lw <= '0';
				for i in 1 to 10 loop
					wait until rising_edge(clk);
				end loop;
				k0_mw <= '1'; -- Start
				wait until rising_edge(clk);
				k0_mw <= '0';
				wait until rising_edge(clk);
			end if;
			wait until rising_edge(clk);
		end loop;
		---- END OF TESTING --------------

		---- KEY SEARCH ------------------
		-- Resetting
		sresetn <= '0';
		for i in 1 to 10 loop
			wait until rising_edge(clk);
		end loop;
		sresetn <= '1';
		wait until rising_edge(clk);
		-- Starting the machine 
		k0_mw <= '1';
		wait until rising_edge(clk);
		k0_mw <= '0';
		wait until rising_edge(clk);

		while found /= '1' loop -- Asa found equals '1' the simulation stops
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;

end architecture sim;

-- vim: set ts=4 sw=4 tw=90 noet :
