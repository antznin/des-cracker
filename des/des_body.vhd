library ieee;
use ieee.std_logic_1164.all;
use std.env.all;
use work.des_pkg.all;
use work.des_cst.all;

package body des_pkg is

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

function right_shift (w:w28; amount : natural) return w28 is
  	   begin
	   if amount=2 then
	      return w(26 downto 1) & w(28 downto 27);
	   elsif amount=1 then
	      return w(27 downto 1) & w(28);
	   else
	      assert false report "ERROR" severity failure;
	   end if;
end right_shift;


function pc1 (w : w56) return w56 is
           variable output1 : w28;
           variable output2 : w28;
           variable c : natural;
	   begin
	   for i in 1 to 28 loop
             output1(i) := w(pc1_table(i));
	   end loop;
           c:=28;
           for i in 1 to 28 loop
             c:=28+i;
             output2(i) := w(pc1_table(c));
	   end loop;
	   return output1&output2;
end pc1;	


function pc2(w1 : w28; w2 : w28) return w48 is
           variable input : w56;
           variable output : w48;
	   begin
           for i in 1 to 48 loop
             output(i) := input(pc2_table(i));
	   end loop;
	   return output;
end pc2;

end package body des_pkg;
