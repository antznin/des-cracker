library ieee;
use ieee.std_logic_1164.all;

entity pc1 is
	port (
		clk:       in  std_ulogic;
		sresetn:   in  std_ulogic;
		pc1_in:    in  std_ulogic_vector(63 downto 0);
       		pc1_out1:  out std_ulogic_vector(27 downto 0);
       		pc1_out2:  out std_ulogic_vector(27 downto 0);
		power:     in  std_ulogic -- active or not
	);
end entity pc1;	

architecture rtl of pc1 is

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' or power = '0' then
				pc1_out1 <= (others => '0');
				pc1_out2 <= (others => '0');
			else
			pc1_out1 <= 
				pc1_in(56) & pc1_in(48) & pc1_in(40)  & pc1_in(32) & pc1_in(24) &
				pc1_in(16) & pc1_in(8)  & pc1_in(0)   & pc1_in(57) & pc1_in(49) &
				pc1_in(41) & pc1_in(33) & pc1_in(25)  & pc1_in(17) & pc1_in(9)  &
				pc1_in(1)  & pc1_in(58) & pc1_in(50)  & pc1_in(42) & pc1_in(34) &
				pc1_in(26) & pc1_in(18) & pc1_in(10)  & pc1_in(2)  & pc1_in(59) &
				pc1_in(51) & pc1_in(43) & pc1_in(35);

			pc1_out2 <=
				pc1_in(62) & pc1_in(54) & pc1_in(46) & pc1_in(38) & pc1_in(30) &
				pc1_in(22) & pc1_in(14) & pc1_in(6)  & pc1_in(61) & pc1_in(53) &
				pc1_in(45) & pc1_in(37) & pc1_in(29) & pc1_in(21) & pc1_in(13) &
				pc1_in(5)  & pc1_in(60) & pc1_in(52) & pc1_in(44) & pc1_in(36) &
				pc1_in(28) & pc1_in(20) & pc1_in(12) & pc1_in(4)  & pc1_in(27) &
				pc1_in(19) & pc1_in(11) & pc1_in(3);
			end if;
		end if;
	end process;

end architecture rtl;
