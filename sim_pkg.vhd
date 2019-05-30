library ieee;
use ieee.std_logic_1164.all;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use work.des_pkg.all;

package sim_pkg is

function read_sim(aclk : std_ulogic; addr : w32)            return w32;
function write_sim(aclk : std_ulogic; addr : w32) return w32;

end package sim_pkg;

package body sim_pkg is

function read_sim(aclk : std_ulogic; addr: w32) return w32 is
    
  s0_axi_rready <='0';  
  s0_axi_araddr <=w32;
  s0_axi_arvalid <= '1';
  wait until rising_edge(aclk); 
  s0_axi_arvalid <= '0';
  s0_axi_rready <='1';
end read_sim;


function write_sim(aclk : std_ulogic; addr : w32; data: w32) return  is
  s0_axi_bready <='0';
  s0_axi_awaddr <=w32;
  s0_axi_awvalid <= '1';
  s0_axi_wvalid <='1';
  s0_axi_wdata <= w32;
  wait until rising_edge(aclk);
  s0_axi_awvalid <= '0';
  s0_axi_wvalid <='0';
  s0_axi_bready <='1';
end write_sim;


end package body sim_pkg;
