use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;

entity des_cracker_sim is
	port (
		k1:    out w56;
		k_req: out w56; -- Key to send in case of requests
		found: out std_ulogic
	);
end entity des_cracker_sim;


architecture rtl of des_cracker_sim is

	signal clk:      std_ulogic;
	signal sresetn:  std_ulogic;
	signal enable:   std_ulogic; -- "Power button"
	signal p:        w64;
	signal c:        w64;
	signal k0:       w56;
	signal k0_mw:   std_ulogic; -- MSB of k0 written
	signal k0_lw:   std_ulogic; -- LSB of k0 written
	signal k_mr:    std_ulogic; -- MSB of k read
	signal k_lr:    std_ulogic; -- LSB of k read
    
begin   

	cracker : entity work.des_cracker(rtl)
	generic map ( N => 7 )
	port map (
		clk     => clk,
		sresetn => sresetn,
		enable  => enable,
		p       => p,
		c       => c,
		k0      => k0,
		k1      => k1,
		k0_mw   => k0_mw,
		k0_lw   => k0_lw,
		k_mr    => k_mr,
		k_lr    => k_lr,
		found   => found,
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
	begin
		---- Defining default values -----
		p  <= x"f0f0f0f0f0f0f0f0";
		c  <= x"0b6a2cd8d51bb869";
		k0 <= x"00000000000000";
		-- Found key should be 00000000000408 (56 bits)
		k0_lw <= '0';
		k0_mw <= '0';

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
			-- Freezing the machines sometines to see if they start back alright
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
		-- Starting the machines
		k0_mw <= '1';
		wait until rising_edge(clk);
		k0_mw <= '0';
		wait until rising_edge(clk);

		while found /= '1' loop -- Asa found equals '1' the simulation stops
			wait until rising_edge(clk);
		end loop;
		finish;
	end process;

	------- KEY REQUESTS -----------------
	-- This process periodically requests the last of the computed keys, as the CPU
	-- would do to track the progress of the cracking
	process
	begin
		k_lr <= '1'; -- Reading LSB of k
		wait until rising_edge(clk);
		k_lr <= '0';
		for i in 1 to 5 loop
			wait until rising_edge(clk);
		end loop;
		k_mr <= '1'; -- Reading MSB of k
		wait until rising_edge(clk);
		k_mr <= '0';
		for i in 1 to 20 loop
			wait until rising_edge(clk);
		end loop;
	end process;

end rtl;
