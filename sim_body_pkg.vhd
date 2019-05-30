library ieee;
use ieee.std_logic_1164.all;

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use des_pkg

package sim_pkg is

function read_sim(aclk : std_ulogic, sig : w32)            return w32;
function write_sim(aclk : std_ulogic, sig : w32) return w32;

end package sim_pkg;

package body sim_pkg is

function read_sim(aclk : std_ulogic, sig: w32) return w32 is


end read_sim;

function write_sim(aclk : std_ulogic, sig : w32) return w32 is

end write_sim;
