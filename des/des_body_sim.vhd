use std.env.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;
use work.des_cst.all;

entity des_body_sim is
	port(
                ip_out: out std_ulogic_vector(64 downto 1);
                iip_out : out std_ulogic_vector(64 downto 1)
	);
end entity des_body_sim;

architecture sim of des_body_sim is
        -- signaux internes
          signal ip_in : w64;
       begin


          
          -- generer ces signaux
        process
          begin
            ip_in <= (others =>'0');

            wait for 10 ns;
            ip_in <= (64 downto 56 =>'1' , others => '0'); --64

            wait for 10 ns;
            
                    ip_out <= ip(ip_in);
	            iip_out <= iip(ip(ip_in)(64 downto 33), ip(ip_in)(32 downto 1));

            

         end process;
       
end architecture sim;
