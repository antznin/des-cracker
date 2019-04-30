library ieee;
use ieee.std_logic_1164.all;
use des_types_pkg.all;
use des_cst_pkg.all;

package body des_pkg is

function ip(w : w64)  return w64 is
	   w_out : out std_ulogic(64 downto 1);
	   begin
	   for i in ip_tab
	       w_out(c) <= w(i);
	   end loop;
	   return w_out;
end ip;	  

function iip(w1 : w32, w2:w32)  return w64 is
	   w_in : in std_ulogic(64 downto 1);
	   w_out : out std_ulogic(64 downto 1);
	   begin
	   w_in <= w1&w2;
	   for i in iip_tab
	       w_out(c) <= w_in(i);
	   end loop;
	   return w_out;
end iip;	

function left_shift (w:w28; amount : natural) return w28 is
  	   begin
	   if amount=2 then
	      return w28(28 to 3) & w28 (1 to 2);
	   elsif amount=1 then
	      return w28(2 to 28) & w28(1);
	   else
	      assert false report 'ERROR' severity failure;
	   end if;
end left_shift;

end package body des_pkg;
