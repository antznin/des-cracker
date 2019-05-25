library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.des_pkg.all;

--! @brief Entity used to search for the key, behaving as a state machine
--! @details This entity is given a plaintext `p` and a ciphertext `c` and looks for the
--! corresponding encryption key. It uses a state machine composed of two states :
--!  * FROZEN : the machine is frozen and thus does nothing and waits for k0_mw to be set
--!  * RUNNING : the machine runs, and thus computes the DES encryption of a current key
--!  (dynamic) and compares its output with `p`. The current key is incremented by N, a
--!  generic parameter, allowing multiples instances of this entity to search for the key.
entity cracking_machine is
	generic (
		N:          integer
	);
	port (
		clk:        in  std_ulogic; --! The clock
		sresetn:    in  std_ulogic; --! Reset signal
		enable:     in  std_ulogic; --! Used to enable or disable the machine
		p:          in  w64;        --! The plaintext
		c:          in  w64;        --! The ciphertext
		found_k:    out w56;        --! Output found key (if ever found)
		starting_k: in  w56;        --! Base / starting key. Where the search starts from
		found:      out std_ulogic; --! Set to '1' if the mach in e found the key
		k0_mw:      in  std_ulogic; --! MSB of k0 written
		k0_lw:      in  std_ulogic; --! LSB of k0 written
		k_req:      out w56         --! Key that may be requested
	);
end entity cracking_machine;

architecture rtl of cracking_machine is

	type states_cracking is (FROZEN, RUNNING);

	signal state_crack: states_cracking;
	signal current_k:   w56;

begin

	k_req <= current_k;

	--! The state machine
	crack_proc: process (clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				state_crack <= FROZEN;
				current_k   <= starting_k; -- Start back on starting_k
				found_k     <= (others => '0');
				found       <= '0';
			elsif enable = '1' then
				case state_crack is
					when FROZEN =>
						state_crack <= FROZEN;
						if k0_mw = '1' then
							state_crack <= RUNNING;
						end if;
					when RUNNING =>
						state_crack <= RUNNING;
						if k0_lw = '1' then
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
