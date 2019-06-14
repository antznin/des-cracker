library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.des_pkg.all;

--! @brief This entity controls the cracking machines and handles key request from CPU.
--! @details It instanciates N machines with the
--! generate clause, and distributes the `starting_k`s of each cracking_machine, thus
--! distributing it as follows : starting_k_t(i) = k0 + i, where starting_k_t represents
--! the N starting keys.
--!
--! This entity also handles the key request function. Its goal is to respond to a CPU
--! request of a the last computed key. Thus, it will freeze the last computed key of the
--! Nth machine until the transaction between the CPU and the cracker is finished.
entity des_ctrl is
	generic (
		N : integer := 4 -- Number of machines
	);
	port (
		clk:       in  std_ulogic; --! The clock
		sresetn:   in  std_ulogic; --! Reset signal
		enable :   in  std_ulogic; --! Used to enable or disable the machine
		p:         in  w64;		   --! The plaintext
		c:         in  w64;        --! The ciphertext
		k0: 	   in  w56;		   --! Received base key
		k1:        out w56;		   --! Found key ti send
		k0_mw:     in  std_ulogic; --! MSB of k0 written
		k0_lw:     in  std_ulogic; --! LSB of k0 written
		k_mr:      in  std_ulogic; --! MSB of k read
		k_lr:      in  std_ulogic; --! LSB of k read
		found:     out std_ulogic; --! Set to 1 when key is found
		k_req:     out w56         --! Key to send in case of requests
	);
end entity des_ctrl;

architecture rtl of des_ctrl is

	type states_request is (UPDATING, FREEZE); --! Key requests states
	signal state_req: states_request;

	signal found_t:   table_bit(1 to N); --! Table containing all the machine's found signals
	signal found_k_t: table56(1 to N);   --! Table containing all the machine's found_k signals
	signal k_req_t:   table56(1 to N);   --! Table containing all the machine's k_req signals

begin

	-- Generate all the machines
	machine_gen : for i in 0 to N-1 generate
	begin
		cracking_machines : entity work.cracking_machine(rtl)
		generic map (
			N          => N
		)
		port map (
			clk        => clk,
			sresetn    => sresetn,
			enable     => enable,
			p          => p,
			c          => c,
			found_k    => found_k_t(i+1),
			starting_k => std_ulogic_vector(unsigned(k0) + i),
			found      => found_t(i+1),
			k0_mw      => k0_mw,
			k0_lw      => k0_lw,
			k_req      => k_req_t(i+1)
		);
	end generate;

	--! As soon as found_t changes, we check if an element equals '1', thus
	--! indicating if a key has been found. It stores the found key in k1.
	found_k_proc: process (clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				k1    <= (others => '0');
				found <= '0';
			elsif enable = '1' then
				for i in 1 to N loop
					if found_t(i) = '1' then
						k1 <= found_k_t(i);
						found <= '1';
					end if;
				end loop;
			end if;
		end if;
	end process;

	--! Key request process
	key_req: process (clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' then
				k_req     <= (others => '0');
				state_req <= UPDATING;
			elsif enable = '1' then
				case state_req is
					when UPDATING =>
						k_req <= k_req_t(N); -- Key update
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
