use std.env.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity des is
  port (
    clk : in std_ulogic;
    ptext : in std_ulogic(64 downto 1);
    ctext : out std_ulogic(64 downto 1);
    key : in std_ulogic(56 downto 1);
    );
end des;


architecture rtl of des is
  --signaux internes
  lptext : std_ulogic_vector(32 downto 1);
  rptext : std_ulogic_vector (32 downto 1);
  k : std_ulogic_vector(48 downto 1);
  c : std_ulogic_vector (28 downto 1);
  d : std_ulogic_vector (28 downto 1);

begin
  if rising_edge(clk) then
    if --reset

  elsif
      lptext <= ip(ptext)(64 downto 32);
      rptext <= ip(ptext)(31 downto 1);
      c <= pc1(key)(56 downto 29);
      d <= pc2(key)(28 downto 1);
      --
  
      
  
 
   
