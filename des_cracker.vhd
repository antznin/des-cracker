library ieee;
use ieee.std_logic_1164.all;
--library unisim;
--use unisim.vcomponents.all;

use std.env.all;

use ieee.numeric_std.all;
use ieee.math_real.all;
use work.des_pkg.all;
use work.des_cst.all;

entity des_cracker is

        generic (
          N : integer 
          );
	port (
		-- Clock and reset
		aclk:            in    std_ulogic;
		aresetn:         in    std_ulogic;
                enable : in std_ulogic;
                p: in w64; -- plaintext, Base Address: 0x000
                c: in w64; -- ciphertext, BA: 0x008
                k: in  w56; -- current secret key, BA: 0x018
                k1: out  table56(1 to N); -- un tableau de k1
                found:   out table_bit(1 to N); -- found devient un tableau de found
	        k0_mw:   in  std_ulogic; -- MSB of k0 written
                k0_lw:   in  std_ulogic; -- LSB of k0 written
                k_mr:    in  std_ulogic; -- MSB of k read
                k_lr:    in  std_ulogic; -- LSB of k read
                k_req:   out table56(1 to N); -- key devient un tableau de key
                test : out table56(1 to N) -- test devient un tableau de test             
	);
end entity des_cracker;

architecture rtl of des_cracker is

signal r : w56;
signal t : integer;
signal x : unsigned(1 to 56);
signal tmp : std_ulogic_vector(1 to 112);
--ulogic ou logic 



begin
           t <= to_integer(unsigned(r));
           x<=to_unsigned(t/N, 56);
           GEN : for i in 0 to N-1 generate -- 2 puissance pN
           begin
           tmp <= std_ulogic_vector(to_unsigned(i,56)*x);
           test(i) <= tmp(1 to 56);
           cracking_machine : entity work.cracking_machine(rtl)
           port map (
             aclk => aclk,
             sresetn => aresetn, -- pourquoi sresetn dans la cracking 
             enable => enable,
             p => p,
             c => c,
             k0 => std_ulogic_vector(to_unsigned(i,56)*x),
             k1 => k1(i),
             found => found(i),
             k0_mw => k0_mw,
             k0_lw => k0_lw,
             k_mr => k_mr,
             k_lr => k_lr,
             k_req => k_req(i)
             );
           end generate GEN;            
end architecture rtl;


-- signal T : w56; -- 2**56 overflow
