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

--	constant axi_resp_okay:   std_ulogic_vector(1 downto 0) := "00";
--	constant axi_resp_slverr: std_ulogic_vector(1 downto 0) := "10";
--	constant axi_resp_decerr: std_ulogic_vector(1 downto 0) := "11";

	signal p:   std_ulogic_vector(63 downto 0); -- plaintext, Base Address: 0x000
	signal c:   std_ulogic_vector(63 downto 0); -- ciphertext, BA: 0x008
	signal k0:  std_ulogic_vector(55 downto 0); -- starting secret key, BA: 0x010
	signal k:   std_ulogic_vector(55 downto 0); -- current secret key, BA: 0x018
	signal k1:  std_ulogic_vector(55 downto 0); -- found secret key, BA: 0x020

	signal p_local:   std_ulogic_vector(63 downto 0); -- plaintext, Base Address: 0x000
	signal c_local:   std_ulogic_vector(63 downto 0); -- ciphertext, BA: 0x008
	signal k0_local:  std_ulogic_vector(55 downto 0); -- starting secret key, BA: 0x010
	signal k_local:   std_ulogic_vector(55 downto 0); -- current secret key, BA: 0x018
	signal k1_local:  std_ulogic_vector(55 downto 0); -- found secret key, BA: 0x020
        

	type states is (idle, waiting);
	signal state_r, state_w, state_crack: states;

begin

	led <= k(33 downto 30);


--incruster process registre dans process cracking--
        reg: process(aclk)
	begin
		if rising_edge(aclk) then
			if aresetn = '0' then
				p      <= (others => '0');
				c   <= (others => '0');
				k0    <= (others => '0');
				k <= (others => '0');
				k1 <= (others => '0');

			elsif 
				p      <= p_local;
				c <= c_local;
				k0 <= k0_local;
                                k    <= functionjenesaisquoi(k);
                                if pc=c then
                                  k1   <= k;                            
                                end if;

			end if;
		end if;
        end process reg;


	write: process(aclk)
		variable add: natural range 0 to 2**10 - 1;
	begin
		if rising_edge(aclk) then
			s0_axi_awready <= '0';
			s0_axi_wready  <= '0';
			if aresetn = '0' then
				s0_axi_bresp  <= axi_resp_okay;
				s0_axi_bvalid <= '0';
				state_w       <= idle;
			else
				case state_w is
					when idle =>
						if s0_axi_awvalid = '1' and s0_axi_wvalid = '1' then
							s0_axi_awready <= '1';
							s0_axi_wready  <= '1';
							s0_axi_bvalid  <= '1';
                                                        if (s0_axi_awaddr >= x"000"
                                                        and s0_axi_awaddr <= x"003") then
                                                          
                                                          s0_axi_bresp <= b"00"; -- OKAY
                                                          p_local(0 to 31) <= s0_axi_wdata;
                                
                                                        elsif (s0_axi_araddr >= x"004"
                                                        and s0_axi_araddr <= x"007") then
                                                          
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          p_local(32 to 61) <= s0_axi_wdata;
                                        
                                                        elsif (s0_axi_araddr >= x"008"
                                                        and s0_axi_araddr <= x"00B") then

                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          c_local(0 to 31) <= s0_axi_wdata;
                                        
                                                        elsif (s0_axi_araddr >= x"00C"
                                                        and s0_axi_araddr <= x"00F") then

                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          c_local(32 to 61) <= s0_axi_wdata;

                                                        elsif (s0_axi_araddr >= x"010"
                                                        and s0_axi_araddr <= x"013") then

                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          k0_local(0 to 31) <= s0_axi_wdata;
                                                          crack_valid<='0';

                                                        elsif (s0_axi_araddr >= x"014"
                                                         and s0_axi_araddr <= x"017") then
                                                          
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          k0_local(32 to 61) <= s0_axi_wdata;
                                                          crack_valid<='1';
                                        
                                                        elsif (s0_axi_awaddr >= x"018" 
                                                         and s0_axi_awaddr <= x"027") then
                                                          
                                                          s0_axi_bresp <= b"10"; -- SLVERR
                                                        else
                                                          s0_axi_bresp <= b"11"; -- DECERR
                                                        end if;                                          
							state_w <= waiting;
						end if;
					when waiting =>
						if s0_axi_bready = '1' then
							s0_axi_bvalid <= '0';
							state_w       <= idle;
						end if;
				end case;
			end if;
		end if;
	end process write;

	read: process(aclk)
	begin
		if rising_edge(aclk) then
			s0_axi_arready <= '0';
			if aresetn = '0' then
				state_r       <= idle;
				s0_axi_rresp  <= axi_resp_okay;
				s0_axi_rvalid <= '0';
				s0_axi_rdata  <= (others => '0');
			else
				case state_r is
					when idle =>
						if s0_axi_arvalid = '1' then
							s0_axi_arready <= '1';
							s0_axi_rvalid  <= '1';
                                                        if (s0_axi_araddr >= x"000"
                                                        and s0_axi_araddr <= x"003") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= p(0 to 31);
                                                        elsif (s0_axi_araddr >= x"003"
                                                        and s0_axi_araddr <= x"007") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= p(32 to 63);
                                                        elsif (s0_axi_araddr >= x"008"
                                                        and s0_axi_araddr <= x"00B") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= c(0 to 31);                                       
                                                        elsif (s0_axi_araddr >= x"00C"
                                                        and s0_axi_araddr <= x"00F") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= c(32 to 61);
                                                        elsif (s0_axi_araddr >= x"010"
                                                        and s0_axi_araddr <= x"013") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= c(0 to 31);  
                                                        elsif (s0_axi_araddr >= x"014"
                                                        and s0_axi_araddr <= x"017") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= "00000000"& k0(32 to 55);
                                                        elsif (s0_axi_araddr >= x"018"
                                                        and s0_axi_araddr <= x"01B") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= k(0 to 31);
                                                        elsif (s0_axi_araddr >= x"01C"
                                                        and s0_axi_araddr <= x"01F") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <="00000000"& k(32 to 55);
                                                        elsif (s0_axi_araddr >= x"020"
                                                        and s0_axi_araddr <= x"023") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= k1(0 to 31);        
                                                        elsif (s0_axi_araddr >= x"024"
                                                        and s0_axi_araddr <= x"027") then
                                                          s0_axi_rresp <= b"00"; -- OKAY
                                                          s0_axi_rdata <= "00000000"& k1(32 to 55);                                        
                                                        else        
                                                          s0_axi_rresp <= b"11"; -- DECERR
                                                          s0_axi_rdata <= (others => '0');
                                                        end if;

							state_r <= waiting;
						end if;
					when waiting =>
						if s0_axi_rready = '1' then
							s0_axi_rvalid <= '0';
							state_r       <= idle;
						end if;
				end case;
			end if;
		end if;
	end process read;

        crack : process(aclk) 
        begin
          if aresetn='0' then
            state_crack <= idle;
            ---
          else
            case state_crack is
               when idle =>
                 pc <= des(p);
                 if pc=c then
                   k1<=k;
                 else -- generer une nouvelle cle
                      
                 if crack_valid='0' then
                   state_crack<=waiting;
                 end if;
                 
              when waiting =>

                 if crack_valid='1' then
                   state_crack<=idle;
                 end if;
        
end architecture rtl;
