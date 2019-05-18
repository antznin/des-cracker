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
                k: in table56(1 to N); -- current secret key, BA: 0x018 -- pq ?
                k1: out  table56(1 to N); -- un tableau de k1
                found:   out table_bit(1 to N); -- found devient un tableau de found
	        k0_mw:   in  table_bit(1 to N); -- MSB of k0 written
                k0_lw:   in  table_bit(1 to N); -- LSB of k0 written
                k_mr:    in  table_bit(1 to N); -- MSB of k read
                k_lr:    in  table_bit(1 to N); -- LSB of k read
                k_req:   out table56(1 to N); -- key devient un tableau de key
                test : out table56(1 to N); -- test devient un tableau de test
                t : out integer;
                r : out w56;
                tmp : out table112(1 to N);
                index : out table_u56(1 to N);
                x : out unsigned(1 to 56)
	);
end entity des_cracker;

architecture rtl of des_cracker is

--signal r : w56;
--signal t : integer;
--signal x : unsigned(1 to 56);
--signal tmp : table112(1 to N);
-- signal index : table_u56(1 to N);




begin

process
begin
           for i in 1 to N loop
           index(i) <=to_unsigned(i,56);
           end loop;
           wait;
end process;

           r <= (27 =>'1', others =>'0'); 
           t <= to_integer(unsigned(r)); 
           x<=to_unsigned(t/N, 56);
           GEN : for i in 1 to N generate
           begin;
           tmp(i)<= std_ulogic_vector(index(i)*x);
           test(i) <= tmp(i)(57 to 112);
           cracking_machine : entity work.cracking_machine(rtl)
           port map (
             aclk => aclk,
             sresetn => aresetn,
             enable => enable,
             p => p,
             c => c,
             k0 => tmp(i)(57 to 112),
             k1 => k1(i),
             found => found(i),
             k0_mw => k0_mw(i),
             k0_lw => k0_lw(i),
             k_mr => k_mr(i),
             k_lr => k_lr(i),
             k_req => k_req(i)
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

