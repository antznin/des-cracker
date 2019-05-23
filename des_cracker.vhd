library ieee;
use ieee.std_logic_1164.all;

use std.env.all;

use ieee.numeric_std.all;
use ieee.math_real.all;
use work.des_pkg.all;

entity des_cracker is
	generic (
		N : integer := 4 -- Number of machines
	);
	port (
		-- Clock and reset
		clk:       in  std_ulogic;
		sresetn:   in  std_ulogic;
		enable :   in  std_ulogic;
		p:         in  w64; -- plaintext, Base Address: 0x000
		c:         in  w64; -- ciphertext, BA: 0x008
		k0: 	   in  w56;
		k1:        out w56;
		k0_mw:     in  std_ulogic; -- MSB of k0 written
		k0_lw:     in  std_ulogic; -- LSB of k0 written
		k_mr:      in  std_ulogic; -- MSB of k read
		k_lr:      in  std_ulogic; -- LSB of k read
		k_req:     out w56 -- Key to send in case of requests
	);
end entity des_cracker;

architecture rtl of des_cracker is

	type states_request  is (UPDATING, FREEZE);
	signal state_req:   states_request;

	signal found_t:   table_bit(1 to N); -- table containing all mach in e found signals
	signal found_k_t: table56(1 to N); -- table containing all mach in e found_k signals
	signal k_req_t:   table56(1 to N); -- All requested keys

begin

	-- Generate all the machines
	machine_gen : for i in 0 to N-1 generate
	begin
		cracking_machines : entity work.cracking_machine(rtl)
		generic map (
			N          => N,
			starting_k => std_ulogic_vector(unsigned(k0) + i)
		)
		port map (
			clk     => clk,
			sresetn => sresetn,
			enable  => enable,
			p       => p,
			c       => c,
			found_k => found_k_t(i+1),
			found   => found_t(i+1),
			k0_mw   => k0_mw,
			k0_lw   => k0_lw,
			k_req   => k_req_t(i+1)
		);
	end generate;

	-- Synchronous process to reset signals
	sync: process (clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				found_t   <= (others => '0');
				found_k_t <= (others => (others => '0'));
				k1        <= (others => '0');
				k_req     <= (others => '0');
				k_req_t   <= (others => (others => '0'));
			end if;
		end if;
	end process;

	-- Key request process
	key_req: process (clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				state_req   <= UPDATING;
			elsif enable = '1' then
				case state_req is
					when UPDATING =>
						k_req <= k_req_t(N-1); -- Key update
						state_req <= UPDATING;
						if k_lr = '1' then
							state_req <= FREEZE;
						end if;
					when FREEZE =>
						state_req <= FREEZE;
						if k_mr = '1' then
							state_req <= UPDATING;
						end if;
				end case;
			end if;
		end if;
	end process;

end architecture rtl;

-- vim: set ts=4 sw=4 tw=90 noet :
