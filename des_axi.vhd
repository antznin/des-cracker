library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.des_cst.all;

entity axi is
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

		led:             out   std_ulogic_vector(3 downto 0);
		irq: 		 out   std_ulogic
	);
end entity axi;

architecture rtl of axi is

	signal p:       std_ulogic_vector(63 downto 0); -- plaintext, Base Address: 0x 000
	signal c:       std_ulogic_vector(63 downto 0); -- ciphertext, BA:          0x 008
	signal k0:      std_ulogic_vector(55 downto 0); -- starting secret key, BA: 0x 010
    signal k1:      std_ulogic_vector(55 downto 0); -- found secret key, BA:    0x 020
    signal k0_lw :  std_ulogic;
    signal k0_mw :  std_ulogic;
    signal k_mr :   std_ulogic;
    signal k_lr :   std_ulogic;
    signal k_req :  std_ulogic_vector(55 downto 0);
    signal found :  std_ulogic;
    signal enable : std_ulogic;

    type states is (running, waiting);
    signal state_r, state_w: states;
        
begin

	led <= k_req(33 downto 30);       

    des_cracker : entity work.des_cracker(rtl)
    generic map (
		N => 7
	)
    port map (
		clk     => aclk,
		sresetn => aresetn,
		enable  => '1', -- temporarily
		p       => p,
		c       => c,
		k0      => k0,
		k1      => k1,
		found   => found,
		k0_lw   => k0_lw,
		k0_mw   => k0_mw,
		k_lr    => k_lr,
		k_mr    => k_mr,
		k_req   => k_req
    );


    process(found)
	begin
		if rising_edge(found) then
			irq <='1';
		else
			irq <='0';
		end if;          
    end process;
            
	process(aclk)
	begin
		if rising_edge(aclk) then
			s0_axi_awready <= '0';
			s0_axi_wready  <= '0';
            k0_lw          <= '0';
            k0_mw          <= '0';
			if aresetn = '0' then
				s0_axi_bresp  <= b"00";
				s0_axi_bvalid <= '0';
				state_w       <= running;
			else
			    case state_w is
					when running =>
						if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
							s0_axi_awready <= '1';
							s0_axi_wready  <= '1';
							s0_axi_bvalid  <= '1';				
							if (s0_axi_awaddr >= x"000" and s0_axi_awaddr <= x"003") then
								s0_axi_bresp <= b"00"; -- OKAY
								p(31 downto 0) <= s0_axi_wdata;
								
							elsif (s0_axi_awaddr >= x"004" and s0_axi_awaddr <= x"007") then
								s0_axi_bresp <= b"00"; -- OKAY
								p(63 downto 32) <= s0_axi_wdata;
								
							elsif (s0_axi_awaddr >= x"008" and s0_axi_awaddr <= x"00B") then
								s0_axi_bresp <= b"00"; -- OKAY
								c(31 downto 0) <= s0_axi_wdata;
							
							elsif (s0_axi_awaddr >= x"00C" and s0_axi_awaddr <= x"00F") then
								s0_axi_bresp <= b"00"; -- OKAY
								c(63 downto 32) <= s0_axi_wdata;

							elsif (s0_axi_awaddr >= x"010" and s0_axi_awaddr <= x"013") then
								s0_axi_bresp <= b"00"; -- OKAY
								k0_lw <='1';
								k0(31 downto 0) <= s0_axi_wdata;
								
							elsif (s0_axi_awaddr >= x"014" and s0_axi_awaddr <= x"017") then
								s0_axi_bresp <= b"00"; -- OKAY
								k0_mw <='1';
								k0(55 downto 32) <= s0_axi_wdata(23 downto 0);

							elsif (s0_axi_awaddr >= x"018" and s0_axi_awaddr <= x"027") then
								s0_axi_bresp <= b"10"; -- SLVERR

							else
								s0_axi_bresp <= b"11"; -- DECERR
							end if;
							state_w <= waiting;
						end if;

                    when waiting =>
						if s0_axi_bready = '1' then
							s0_axi_bvalid <= '0';
							state_w       <= running;
						end if;
				end case;
			end if;
		end if;
	end process;
        
	process(aclk)
	begin
		if rising_edge(aclk) then
            s0_axi_arready <= '0';
            k_lr <='0';
            k_mr <='0';
			if aresetn = '0' then
				state_r       <= running;
				s0_axi_rresp  <= b"00";
				s0_axi_rvalid <= '0';
				s0_axi_rdata  <= (others => '0');
			else
				case state_r is
                	when running =>
                		if s0_axi_arvalid = '1' then
							s0_axi_arready <= '1';
							s0_axi_rvalid  <= '1';

							if (s0_axi_araddr >= x"000" and s0_axi_araddr <= x"003") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= p(31 downto 0);

							elsif (s0_axi_araddr >= x"003" and s0_axi_araddr <= x"007") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= p(63 downto 32);

							elsif (s0_axi_araddr >= x"008" and s0_axi_araddr <= x"00B") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= c(31 downto 0);

							elsif (s0_axi_araddr >= x"00C"and s0_axi_araddr <= x"00F") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= c(63 downto 32);

							elsif (s0_axi_araddr >= x"010" and s0_axi_araddr <= x"013") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= k0(31 downto 0);

							elsif (s0_axi_araddr >= x"014"and s0_axi_araddr <= x"017") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= "00000000" & k0(55 downto 32);

							elsif (s0_axi_araddr >= x"018" and s0_axi_araddr <= x"01B") then
								s0_axi_rresp <= b"00"; -- OKAY
								k_mr <='1';
								s0_axi_rdata <= k_req(31 downto 0);
							
							elsif (s0_axi_araddr >= x"01C" and s0_axi_araddr <= x"01F") then
								s0_axi_rresp <= b"00"; -- OKAY
								k_lr <='1';
								s0_axi_rdata <= "00000000" & k_req(55 downto 32);

							elsif (s0_axi_araddr >= x"020" and s0_axi_araddr <= x"023") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <= k1(31 downto 0);

							elsif (s0_axi_araddr >= x"024"and s0_axi_araddr <= x"027") then
								s0_axi_rresp <= b"00"; -- OKAY
								s0_axi_rdata <=  "00000000" & k1(55 downto 32);                                        

							else        
								s0_axi_rresp <= b"11"; -- DECERR
								s0_axi_rdata <= (others => '0');
							end if;
							state_r <= waiting;
						end if;
					when waiting =>
                    	if s0_axi_rready = '1' then
							s0_axi_rvalid <= '0';
							state_r       <= running;
						end if;
				end case;
			end if;
		end if;
	end process;
end architecture rtl;

-- vim: set ts=4 sw=4 tw=90 noet :
