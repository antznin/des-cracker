library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

use work.des_pkg.all;

entity cracking_machine is
	generic (
		N:          integer
	);
	port (
		clk:        in  std_ulogic;
		sresetn:    in  std_ulogic;
		enable:     in  std_ulogic; -- "Power button"
		p:          in  w64;
		c:          in  w64;
		found_k:    out w56;
		starting_k: in  w56;
		found:      out std_ulogic; -- Set to '1' if the mach in e found the key
		k0_mw:      in  std_ulogic; -- MSB of k0 written
		k0_lw:      in  std_ulogic; -- LSB of k0 written
		k_req:      out w56 -- Key that may be requested
           
	);
end entity cracking_machine;

architecture rtl of cracking_machine is

	type states_cracking is (FROZEN, RUNNING);

	signal state_crack: states_cracking;
	signal current_k:   w56;


begin

	k_req <= current_k;

	-- Cracking process
	process (clk)
		variable has_started: std_ulogic := '0';
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				state_crack <= FROZEN;
				current_k   <= starting_k;
				found_k     <= (others => '0');
				found       <= '0';
				has_started := '0';
			elsif enable = '1' then
				case state_crack is
					when FROZEN =>
						state_crack <= FROZEN;
						if k0_mw = '1' then
							state_crack <= RUNNING;
						end if;
					when RUNNING =>
						state_crack <= RUNNING;
						if has_started = '0' then
							has_started := '1';
							current_k <= starting_k;
						elsif k0_lw = '1' then
							state_crack <= FROZEN;
						else
							if des(p, extend_key(current_k), true) = c then
								state_crack <= FROZEN;
								found       <= '1';
								found_k     <= current_k;
							else
								current_k <= inc(current_k, N);
							end if;
						end if;
				end case;
			end if;
		end if;
	end process;

end rtl;

-- vim: set ts=4 sw=4 tw=90 noet :
