use work.des_cst.all;
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

--! Body of des_pkg, containing all function bodies. Please see des/des_types_pkg.vhd for
--! functions and types description
package body des_pkg is

-- Initial and final permutations
function ip(w : w64)  return w64 is
           variable output : w64;
	   begin
	   for i in 1 to 64 loop 
             output(i) := w(ip_table(i));         
	   end loop;
	   return output;
end ip;	  

function iip(w1 : w32; w2 : w32)  return w64 is
           variable input : w64;
           variable output : w64;
	   begin
	   input := w1&w2;
	   for i in 1 to 64 loop
             output(i) := input(iip_table(i));
	   end loop;
	   return output;
end iip;	

-- Key schedule functions
function extend_key(k_in: w56) return w64 is
begin
	return   k_in(1 to 7)   & "0"
	       & k_in(8 to 14)  & "0"
	       & k_in(15 to 21) & "0"
	       & k_in(22 to 28) & "0"
	       & k_in(29 to 35) & "0"
	       & k_in(36 to 42) & "0"
	       & k_in(43 to 49) & "0"
	       & k_in(50 to 56) & "0";
end extend_key;

function left_shift (w:w28; amount : natural) return w28 is
  	   begin
	   if amount=2 then
	      return w(3 to 28) & w(1 to 2);
	   elsif amount=1 then
	      return w(2 to 28) & w(1);
	   else
             assert false report "ERROR" severity failure;
             return (others =>'0');
	   end if;
end left_shift;

function right_shift (w:w28; amount : natural) return w28 is
  	   begin
	   if amount=2 then
	      return w(27 to 28) & w(1 to 26);
	   elsif amount=1 then
	      return w(28) & w(1 to 27);
	   else
             assert false report "ERROR" severity failure;
             return (others =>'0');
	   end if;
end right_shift;

function pc1 (w : w64) return w56 is
           variable output : w56;
	   begin
	   for i in 1 to 56 loop
             output(i) := w(pc1_table(i));
	   end loop;
	   return output;
end pc1;	

function pc2(w1 : w28; w2 : w28) return w48 is
           variable input : w56;
           variable output : w48;
           begin
           input := w1 & w2; 
           for i in 1 to 48 loop
             output(i) := input(pc2_table(i));
	   end loop;
	   return output;
end pc2;

function ks(k: w64) return rkey_table is
	variable k_t: rkey_table; -- Output key table 
	variable k56: w56;
	variable c, d: w28;
	variable amount: natural;
begin
	k56 := pc1(k);
	c   := k56(1 to 28);
	d   := k56(29 to 56);
	for i in 1 to 16 loop
		if i = 1 or i = 2 or i = 9 or i = 16 then
			amount := 1;
		else
			amount := 2;
		end if;
		c := left_shift(c, amount);
		d := left_shift(d, amount);
		k_t(i) := pc2(c, d);
	end loop;
	return k_t;
end ks;

-- Feistel functions
function p(w : w32) return w32 is
	variable output: w32;
begin
	for i in 1 to 32 loop
		output(i) := w(p_table(i));	
	end loop;	
	return output;
end p;

function e(w : w32) return w48 is
	variable output: w48;
begin
	for i in 1 to 48 loop
		output(i) := w(e_table(i));
	end loop;
	return output;
end e;

function s(w : w48) return w32 is
	variable output:     w32;
	variable sw:         w6;
	variable row, col:   integer;
	variable curr_table: table64_t;
	variable out_s:      w4;
begin
	output := (others => '0');
	for i in 1 to 8 loop
		curr_table := s_table(i);
		sw         := w(6*(i-1) + 1 to 6*i);
		row        := to_integer(unsigned'(sw(1) & sw(6)));
		col        := to_integer(unsigned'(sw(2) & sw(3) & sw(4) & sw(5)));
		out_s      := std_ulogic_vector(to_unsigned(curr_table(row * 16 + col), out_s'length));
		output(4*(i-1) + 1 to 4*i) := out_s;
	end loop;
	return output;
end s;

function f(r : w32; rk : w48) return w32 is
begin
	return p(s(e(r) xor rk));
end f;

-- DES main function
function des (p : w64; k : w64; encipher: boolean) return w64 is
-- encipher :
--	* true : encipher the text
-- 	* false : decipher the text
	variable l, r, l_tmp, r_tmp:  w32;
	variable k_t:   rkey_table;
	variable p_inv: w64; -- internal p
	variable j: natural;
begin
	k_t   := ks(k);
	p_inv := ip(p);
	l_tmp := p_inv(1 to 32); -- L0
	r_tmp := p_inv(33 to 64);  -- R0
	for i in 1 to 16 loop
		if not encipher then
			j := 17 - i;
		else
			j := i;
		end if;
		l     := r_tmp;
		r     := l_tmp xor f(r_tmp, k_t(j));
		l_tmp := l;
		r_tmp := r;
	end loop;	
	return iip(r, l);
end des;


-- Key increment
function inc(k : w56; N : integer) return w56 is
	variable k_tmp : w56;
begin
	return std_ulogic_vector(unsigned(k) + N);
end inc;

end package body des_pkg;

-- vim: set ts=4 sw=4 tw=90 noet :
