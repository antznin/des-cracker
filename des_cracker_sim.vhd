library ieee;
use ieee.std_logic_1164.all;
--library unisim;
--use unisim.vcomponents.all;

use std.env.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.des_pkg.all;
use work.des_cst.all;

entity des_cracker_sim is
  port (
    test : out table56(1 to 4);
    t : out integer;
    r : out w56;
    pi : out unsigned(1 to 56);
    tmp : out table112(1 to 4);
    index : out table_u56(1 to 4);
    x : out unsigned (1 to 56)
    
    );
end entity des_cracker_sim;

architecture rtl of des_cracker_sim is

	signal aclk:     std_ulogic;
	signal aresetn: std_ulogic;
	signal enable:  std_ulogic; -- "Power button"
	signal p:       w64;
	signal c:       w64;
	signal k0:      w56;
        signal k : table56(1 to 4);
        signal k1 : table56(1 to 4);
        signal k_req : table56(1 to 4);
	signal k0_mw:   table_bit(1 to 4); -- MSB of k0 written
	signal k0_lw:  table_bit(1 to 4); -- LSB of k0 written
	signal k_mr:    table_bit(1 to 4); -- MSB of k read
	signal k_lr:  table_bit(1 to 4); -- LSB of k read
        signal found : table_bit(1 to 4);

        
    
 begin   
      cracker : entity work.des_cracker(rtl)
      generic map (N=>4)
      port map(
	aclk    => aclk,
	aresetn => aresetn,
	enable   => enable,
	p     => p,
	c    => c,
        k => k,
        k1 => k1,
        found => found,
        k0_mw => k0_mw,
        k0_lw => k0_lw,
        k_mr => k_mr,
        k_lr => k_lr,
        k_req => k_req,
        test => test,
        r => r,
        t => t,
        pi => pi,
        tmp => tmp,
        index => index,
        x => x
	);

end rtl;
