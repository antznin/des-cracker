library ieee;
use ieee.std_logic_1164.all;

entity initp is
	port (
		clk:      in  std_ulogic;
		sresetn:  in  std_ulogic;
		input:    in  std_ulogic_vector(63 downto 0);
       		output:   out std_ulogic_vector(63 downto 0);
		power:    in  std_ulogic -- active or not
	);
end entity initp;	

architecture rtl of initp is

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if sresetn = '0' or power = '0' then
				output <= (others => '0');
			else
				output <= input(57) & input(49) & input(41) & input(33) & input(25) & input(17) &
					  input(9)  & input(1)  & input(59) & input(51) & input(43) & input(35) &
					  input(27) & input(19) & input(11) & input(3)  & input(61) & input(53) &
					  input(45) & input(37) & input(29) & input(21) & input(13) & input(5)  &
					  input(63) & input(55) & input(47) & input(39) & input(31) & input(23) &
					  input(15) & input(7)  & input(56) & input(48) & input(40) & input(32) &
					  input(24) & input(16) & input(8)  & input(0)  & input(58) & input(50) &
					  input(42) & input(34) & input(26) & input(18) & input(10) & input(2)  &
					  input(60) & input(52) & input(44) & input(36) & input(28) & input(20) &
					  input(12) & input(4)  & input(62) & input(54) & input(46) & input(38) &
					  input(30) & input(22) & input(14) & input(6);
			end if;
		end if;
	end process;

end architecture rtl;
