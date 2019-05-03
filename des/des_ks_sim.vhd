use std.env.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;
use work.des_cst.all;

entity des_ks_sim is
	port(
                pc1_out : out std_ulogic_vector(56 downto 1);
                pc2_out : out std_ulogic_vector(48 downto 1);
		left_out: out std_ulogic_vector(28 downto 1)
	);
end entity des_ks_sim;

architecture sim of des_ks_sim is
        -- signaux internes
          signal left_in : w28;
          signal pc1_in : w64;
          signal pc2_in : w48;
          signal pc2_in1 : w28;
          signal pc2_in2 : w28;
       begin
	process
          begin
            left_in <= (others =>'0');
            pc1_in <= (others =>'0');
            pc2_in <= (others =>'0');
            pc2_in1 <= (others =>'0');
            pc2_in2 <= (others =>'0');

            wait for 10 ns;
          
            left_in<= ( 28 downto 20 =>'1', others =>'0');-- 28
            pc1_in <= "1111111111111111111111111111111100000000000000000000000000000000";
            pc2_in1  <= "1111000011110000111100001111";--(28 downto 26 => '0', others =>'1'); --28
            pc2_in2 <= "1111000011110000111100001111";--(28 downto 26 => '1', others =>'0'); --28
            

            wait for 10 ns;
            

	      	    left_out <= left_shift(left_in,2);
                    pc1_out <= pc1(pc1_in);
                    pc2_out <= pc2(pc2_in1, pc2_in2) ;
            

         end process;
       
end architecture sim;

