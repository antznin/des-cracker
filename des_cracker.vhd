library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity des_cracker is
	port (
		-- Clock and reset
		aclk:            in    std_ulogic;
		aresetn:         in    std_ulogic;
		-- Read address channel
		s0_axi_araddr:   in    std_ulogic_vector(11 downto 0);
		s0_axi_arvalid:  in    std_ulogic;
		s0_axi_arready:  out   std_ulogic;
		-- Write address channel
		s0_axi_awaddr:   in    std_ulogic_vector(11 downto 0);
		s0_axi_awvalid:  in    std_ulogic;
		s0_axi_awready:  out   std_ulogic;
		-- Write data channel
		s0_axi_wdata:    in    std_ulogic_vector(31 downto 0);
		s0_axi_wstrb:    in    std_ulogic_vector(3 downto 0);
		s0_axi_wvalid:   in    std_ulogic;
		s0_axi_wready:   out   std_ulogic;
		-- Read data channel
		s0_axi_rdata:    out   std_ulogic_vector(31 downto 0);
		s0_axi_rresp:    out   std_ulogic_vector(1 downto 0);
		s0_axi_rvalid:   out   std_ulogic;
		s0_axi_rready:   in    std_ulogic;
		-- Write response channel
		s0_axi_bresp:    out   std_ulogic_vector(1 downto 0);
		s0_axi_bvalid:   out   std_ulogic;
		s0_axi_bready:   in    std_ulogic;

		led:             out   std_ulogic_vector(3 downto 0)
		irq: 		 out   std_ulogic;
	);
end entity des_cracker;

architecture rtl of des_cracker is

	signal p:   std_ulogic_vector(63 downto 0); -- plaintext, Base Address: 0x000
	signal c:   std_ulogic_vector(63 downto 0); -- ciphertext, BA: 0x008
	signal k0:  std_ulogic_vector(55 downto 0); -- starting secret key, BA: 0x010
	signal k:   std_ulogic_vector(55 downto 0); -- current secret key, BA: 0x018
	signal k1:  std_ulogic_vector(55 downto 0); -- found secret key, BA: 0x020

begin

end architecture rtl;
