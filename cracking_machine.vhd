library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

use work.des_pkg.all;

entity cracking_machine is
	port (
		aclk:    in  std_ulogic;
		sresetn: in  std_ulogic;
		p:       in  w64;
		c:       out w64;
		k0:      in  w56;
		k1:      out w56;
		found:   out std_ulogic;
		k0_mw:   in  std_ulogic; -- MSB of k0 written
		k0_lw:   in  std_ulogic; -- LSB of k0 written
		k_mr:    in  std_ulogic; -- MSB of k read
		k_lr:    in  std_ulogic  -- LSB of k read
	);
end entity cracking_machine;

architecture rtl of cracking_machine is

	type states_crack is (FROZEN, RUNNING, KEY_REQUEST);

	signal state, next_state: states_crack;
	signal current_k: w56 := k0;

begin

	-- Synchronous process
	sync_proc: process (aclk)
	begin
		if rising_edge(aclk) then
			if sresetn = '0' then
				state <= FROZEN;
			else
				state <= next_state;
			end if;
		end if;
	end process;

	state_proc: process (k0_lw, k0_mw, k_lr, k_mr)
	begin

		case state is
			when FROZEN =>
				next_state <= FROZEN;
				if k0_mw = '1' then
					next_state <= RUNNING;
				end if;
			when RUNNING =>
				
				if des(p, current_k, true) = c then
					found <= '1';
					k1 <= current_k;
				else
					current_k <= kg(current_k);
				end if;

				next_state <= RUNNING;
				if k0_lw = '1' then
					next_state <= FROZEN;
				elsif k_lr = '1' then
					next_state <= KEY_REQUEST;
				end if;
			when KEY_REQUEST =>
				if k_mr = '1' then
					next_state <= RUNNING;
				elsif k0_lw = '1' then
					next_state <= FROZEN;
				end if;
		end case;
					
	end process;

end rtl;

-- vim: set ts=4 sw=4 tw=90 noet :
