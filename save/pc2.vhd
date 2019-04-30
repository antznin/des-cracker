library ieee;
use ieee.std_logic_1164.all;

entity pc2 is
	port (
		clk:       in  std_ulogic;
		sresetn:   in  std_ulogic;
		pc2_in1:   in  std_ulogic_vector(27 downto 0);
		pc2_in2:   in  std_ulogic_vector(27 downto 0);
       		pc2_out1:  out std_ulogic_vector(47 downto 0);
		power:     in  std_ulogic -- active or not
	);
end entity pc2;	

architecture rtl of pc2 is

	signal cd: std_ulogic_vector(55 downto 0); -- Concatenation of inputs

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' or power = '0' then
				cd <= (others => '0');
			else 
				cd <= pc2_in1 & pc2_in2;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' or power = '0' then
				pc2_out1 <= (others => '0');
			else
				pc2_out1 <=
					cd(13) & cd(16) & cd(10) & cd(23) & cd(0)  & cd(4)  & cd(2) &
					cd(27) & cd(14) & cd(5)  & cd(20) & cd(9)  & cd(22) &
					cd(18) & cd(11) & cd(3)  & cd(25) & cd(7)  & cd(15) & cd(6) &
					cd(26) & cd(19) & cd(12) & cd(1)  & cd(40) & cd(51) &
					cd(30) & cd(36) & cd(46) & cd(54) & cd(29) & cd(39) &
					cd(50) & cd(44) & cd(32) & cd(47) & cd(43) & cd(48) &
					cd(38) & cd(55) & cd(33) & cd(52) & cd(45) & cd(41) &
					cd(49) & cd(35) & cd(28) & cd(31);
			end if;
		end if;
	end process;

end architecture rtl;
