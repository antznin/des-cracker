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
          N : integer :=4 
          );
	port (
		-- Clock and reset
		aclk:            in    std_ulogic;
		sresetn:         in    std_ulogic;
                enable : in std_ulogic;
                p: in w64; -- plaintext, Base Address: 0x000
                c: in w64; -- ciphertext, BA: 0x008
                k1_t: out  table56(1 to N); -- un tableau de k1
                found_t:   out table_bit(1 to N); -- found devient un tableau de found
	        k0_mw_t:   in  table_bit(1 to N); -- MSB of k0 written
                k0_lw_t:   in  table_bit(1 to N); -- LSB of k0 written
                k_mr_t:    in  table_bit(1 to N); -- MSB of k read
                k_lr_t:    in  table_bit(1 to N); -- LSB of k read
                k_req_t:   out table56(1 to N); -- key devient un tableau de key
                tmp : out table112(1 to N)
	);
end entity des_cracker;

architecture rtl of des_cracker is


constant k : unsigned (1 to 56) := x"10000000000000"/N;
--constant index_t : table_u56(1 to N);


begin





GEN : for i in 1 to N generate
begin
tmp(i)<= std_ulogic_vector(i*k);
cracking_machine : entity work.cracking_machine(rtl)
port map (
aclk => aclk,
sresetn => sresetn,
enable => enable,
p => p,
c => c,
k0 => tmp(i)(57 to 112),
k1 => k1_t(i),
found => found_t(i),
k0_mw => k0_mw_t(i),
k0_lw => k0_lw_t(i),
k_mr => k_mr_t(i),
k_lr => k_lr_t(i),
k_req => k_req_t(i)
);
end generate;


end architecture rtl;





-- questions 
--comment simuler ce qu'il y a dans la cracking machine
--probleme d'overflow on peut avoir des intervalles seulement de 2^27/N au max
--au dessus ca crache
--comment arrondir le nombre de 112 bits en 56 bits
--comprendre comment fonctionne la generate loop
--pourquoi sresetn dans la cracking

