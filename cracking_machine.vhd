library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.des_pkg.all;

entity cracking_machine is
	port (
		aclk:    in  std_ulogic;
		sresetn: in  std_ulogic;
		enable:  in  std_ulogic; -- "Power button"
		p:       in  w64;
		c:       in  w64;
		k0:      in  w56;
		k1:      out w56;
		found:   out std_ulogic; -- Set to '1' if the mach in e found the key
		k0_mw:   in  std_ulogic; -- MSB of k0 written
		k0_lw:   in  std_ulogic; -- LSB of k0 written
		k_mr:    in  std_ulogic; -- MSB of k read
		k_lr:    in  std_ulogic; -- LSB of k read
		k_req:   out w56 -- Key to send in case of requests
	);
end entity cracking_machine;

architecture rtl of cracking_machine is

	type states_cracking is (FROZEN, RUNNING);
	type states_request  is (UPDATING, FREEZE);

	signal state_crack, next_state_crack: states_cracking;
	signal state_req, next_state_req:     states_request;
	signal current_k:                     w56 := k0;

begin

	-- Synchronous process
	sync_proc: process (aclk)
	begin
		if rising_edge(aclk) then
			if sresetn = '0' then
				state_crack <= FROZEN;
				state_req   <= UPDATING;
			elsif enable = '1' then
				state_crack <= next_state_crack;
				state_req   <= next_state_req;
			end if;
		end if;
	end process;

	-- State processes
	--   Cracking machine itself
	state_crack_proc: process (k0_lw, k0_mw)
	begin
		case state_crack is
			when FROZEN =>
				next_state_crack <= FROZEN;
				if k0_mw = '1' then
					next_state_crack <= RUNNING;
				end if;

			when RUNNING =>
				if des(p, current_k, true) = c then
					found <= '1';
					k1 <= current_k;
				else
					current_k <= kg(current_k);
				end if;
				next_state_crack <= RUNNING;
				if k0_lw = '1' then
					next_state_crack <= FROZEN;
				end if;
		end case;
	end process;

	--   Key request machine
	state_request_proc: process (k_lr, k_mr)
	begin
		case state_req is
			when UPDATING =>
				k_req <= current_k; -- Key update
				next_state_req <= UPDATING;
				if k_lr = '1' then
					next_state_req <= FREEZE;
				end if;
			when FREEZE =>
				next_state_req <= FREEZE;
				if k_mr = '1' then
					next_state_req <= UPDATING;
				end if;
		end case;
	end process;

end rtl;

-- vim: set ts=4 sw=4 tw=90 noet :
