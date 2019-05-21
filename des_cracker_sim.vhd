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
    tmp : out table112(1 to 4)
    );
end entity des_cracker_sim;

architecture rtl of des_cracker_sim is

	signal aclk:     std_ulogic;
	signal sresetn: std_ulogic;
	signal enable:  std_ulogic; -- "Power button"
	signal p:       w64;
	signal c:       w64;
	signal k0:      w56;
        signal k_t : table56(1 to 4);
        signal k1_t : table56(1 to 4);
        signal k_req_t : table56(1 to 4);
	signal k0_mw_t:   table_bit(1 to 4); -- MSB of k0 written
	signal k0_lw_t:  table_bit(1 to 4); -- LSB of k0 written
	signal k_mr_t:    table_bit(1 to 4); -- MSB of k read
	signal k_lr_t:  table_bit(1 to 4); -- LSB of k read
        signal found_t : table_bit(1 to 4);

        
    
 begin   
      cracker : entity work.des_cracker(rtl)
      generic map (N=>4)
      port map(
	aclk    => aclk,
	sresetn => sresetn,
	enable   => enable,
	p     => p,
	c    => c,
        k1_t => k1_t,
        found_t => found_t,
        k0_mw_t => k0_mw_t,
        k0_lw_t => k0_lw_t,
        k_mr_t => k_mr_t,
        k_lr_t => k_lr_t,
        k_req_t => k_req_t,
        tmp => tmp
	);

end rtl;
