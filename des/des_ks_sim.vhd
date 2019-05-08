use std.env.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;
use work.des_cst.all;

entity des_ks_sim is
	port(
                pc1_out : out w56;
                pc2_out : out w48;
		left_out: out w28;
                key_out : out key_table;
                k_out : out w56
	);
end entity des_ks_sim;

architecture sim of des_ks_sim is
        -- signaux internes
          signal left_in : w28;
          signal pc1_in : w64;
          signal pc2_in : w48;
          signal pc2_in1 : w28;
          signal pc2_in2 : w28;
          signal key_in : w64;
          signal k_in : w56;
          
       begin
       process
         begin
           key_in <= (others =>'0');

        --   for i in 1 to 18 loop
             key_in <= (1 =>'1', others =>'0');
             wait for 10 ns;
        --   end loop;
       end process;

       key_out <= ks(key_in); -- essayer de le rentrer a l'interieur 
           
   
	process
          begin
            left_in <= (others =>'0');
            pc1_in <= (others =>'0');
            pc2_in <= (others =>'0');
            pc2_in1 <= (others =>'0');
            pc2_in2 <= (others =>'0');
            k_in <= (others=>'0');

            wait for 10 ns;
          
            left_in<= ( 28 downto 20 =>'1', others =>'0');-- 28
            pc1_in <= (1 =>'1', others =>'0');
          
        --    pc2_in1  <= "1111000011110000111100001111";
        --    pc2_in2 <= "1111000011110000111100001111";
            pc2_in1 <= (22 => '1',others => '0');
            k_in <=(1=>'1', others =>'0');
            pc2_in2 <= (others =>'0');
            wait for 10 ns; -- essayer de l'enlever
            

	      	    left_out <= left_shift(left_in,2);
                    pc1_out <= pc1(pc1_in);
                    pc2_out <= pc2(pc2_in1, pc2_in2) ;

                      k_out <= kg(k_in);

         end process;
       
end architecture sim;

