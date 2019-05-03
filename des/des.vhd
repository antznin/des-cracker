use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity des is
  port (
    clk : in std_ulogic;
    sresetn : in std_ulogic;
    initial : in std_ulogic(64 downto 1);
    key : in std_ulogic(56 downto 1);
    output : out std_ulogic(64 downto 1);
    );
end des;

architecture rtl of des is
  --signaux internes
  l : std_ulogic_vector(32 downto 1);
  r : std_ulogic_vector (32 downto 1);
  k : std_ulogic_vector(48 downto 1);
  c : std_ulogic_vector (28 downto 1);
  d : std_ulogic_vector (28 downto 1);
  
begin

      c <= leftshift(c);
      d <= leftshift(d);
      k <= pc2(c,d);


  

begin
  if rising_edge(clk) then
    if sresetn='0' then
      --tous les registres a zero
      --output a zero

    elsif
      --initial permutation
      l      <= ip(ptext) 64 downto 32);
      r      <= ip(ptext)(31 downto 1);
      --ki et f + l
    

    -- r prend ce resultat, l prend l'autre

    -- final permutation
    output <= (r,l);

begin
  if rising_edge(clk) then
    
    if sresetn='0' then
        c_ini <= pc1(key)(56 downto 29);
        d_ini <= pc1(key)(28 downto 1);
    elsif
      --PC1
      c <= pc1(key)(56 downto 29);
      d <= pc1(key)(28 downto 1);
      --LS

      --PC2

      --output ki


 
   
