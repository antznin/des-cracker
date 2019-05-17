library ieee;
use ieee.std_logic_1164.all;
library unisim;
--use unisim.vcomponents.all;

use std.env.all;

use ieee.numeric_std.all;
use ieee.math_real.all;
use work.des_pkg.all;
use work.des_cst.all;

entity des_cracker is

        generic (
          N : integer :=4
          );
	port (
		-- Clock and reset
		aclk:            in    std_ulogic;
		aresetn:         in    std_ulogic;
                enable : in std_ulogic;
                p: in w56; -- plaintext, Base Address: 0x000
                c: in w56; -- ciphertext, BA: 0x008
                k: in  w56; -- current secret key, BA: 0x018
                k1: out  w56; -- found secret key, BA: 0x020
                found:   out std_ulogic; -- Set to '1' if the mach in e found the key
	        k0_mw:   in  std_ulogic; -- MSB of k0 written
                k0_lw:   in  std_ulogic; -- LSB of k0 written
                k_mr:    in  std_ulogic; -- MSB of k read
                k_lr:    in  std_ulogic; -- LSB of k read
                k_req:   out w56 -- Key to send in case of requests
                
	);
end entity des_cracker;

architecture rtl of des_cracker is

signal X : w56;
-- signal T : w56; -- 2**56 overflow



begin
           X<= (1 to 56-N => '1', others => '0');
           GEN : for i in 0 to N-1 generate -- 2 puissance pN
           begin 
           cracking_machine : entity work.cracking_machine(rtl)
           port map (
             aclk => aclk,
             sresetn => aresetn, -- pourquoi sresetn dans la cracking 
             enable => enable,
             p => p,
             c=>c,
             k0 => std_logic_vector(unsigned(i) * unsigned(X)),
             k1 =>k1,
             found => found,
             k0_mw => k0_mw,
             k0_lw => k0_lw,
             k_mr => k_mr,
             k_lr => k_lr,
             k_req => k_req
             );
           end generate GEN;            
end architecture rtl;
