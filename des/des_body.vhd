library ieee;
use ieee.std_logic_1164.all;
use std.env.all;
use work.des_types.all;
use work.des_cst.all;

package body des_body is

function ip(w : w64)  return w64 is
  variable output : w64;
	   begin
	   for i in 1 to 64 loop 
             output(i) := w(ip_table(i));
         
	   end loop;
	   return output;
end ip;	  

function iip(w1 : w32; w2:w32)  return w64 is
           variable input : w64;
           variable output : w64;
	   begin
	   input := w1&w2;
	   for i in 1 to 64 loop
             output(i) := input(iip_table(i));
	   end loop;
	   return output;
end iip;	

function left_shift (w:w28; amount : natural) return w28 is
  	   begin
	   if amount=2 then
	      return w(2 downto 1) & w(28 downto 3);
	   elsif amount=1 then
	      return w(1) & w(28 downto 2);
	   else
	      assert false report "ERROR" severity failure;
	   end if;
end left_shift;

end package body des_body;
