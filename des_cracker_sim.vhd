library ieee;
use ieee.std_logic_1164.all;
--library unisim;
--use unisim.vcomponents.all;

use std.env.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.des_pkg.all;
use work.des_cst.all;

entity sim is
  port (
    test : out table56(1 to 4)
    );
end entity sim;

architecture rtl of sim is

	signal aclk:     std_ulogic;
	signal aresetn: std_ulogic;
	signal enable:  std_ulogic; -- "Power button"
	signal p:       w64;
	signal c:       w64;
	signal k0:      w56;
        signal k : w56;
        signal k1 : table56(1 to 4);
        signal k_req : table56(1 to 4);
	signal k0_mw:   std_ulogic; -- MSB of k0 written
	signal k0_lw:   std_ulogic; -- LSB of k0 written
	signal k_mr:    std_ulogic; -- MSB of k read
	signal k_lr:    std_ulogic; -- LSB of k read
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
        test => test
	);

end rtl;
