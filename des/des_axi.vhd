library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

use work.des_pkg.all;
use work.des_cst.all;

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

		led:             out   std_ulogic_vector(3 downto 0);
		irq: 		 out   std_ulogic
	);
end entity des_cracker;

architecture rtl of des_cracker is

	signal p:   w64; -- plaintext, Base Address: 0x000
	signal c:   w64; -- ciphertext, BA: 0x008
	signal k0:  w56; -- starting secret key, BA: 0x010
	signal k:   w56; -- current secret key, BA: 0x018
	signal k1:  w56; -- found secret key, BA: 0x020

	signal p_local:   w64; -- plaintext, Base Address: 0x000
	signal c_local:   w64; -- ciphertext, BA: 0x008
	signal k0_local:  w56; -- starting secret key, BA: 0x010
	signal k_local:   w56; -- current secret key, BA: 0x018
	signal k1_local:  w56; -- found secret key, BA: 0x020

        signal crack_wvalid : std_ulogic;
        signal crack_rvalid : std_ulogic;


type states is (idle, waiting);
signal state_r, state_w: states;
        
type states_crack is (frozen, running);
signal state_cr: states_crack;
        
begin

	led  <=k(30 to 33); -- ATTENTION DOWNTO NON RESPECTE


	process(aclk)
		variable add: natural range 0 to 2**10 - 1;
	begin
		if rising_edge(aclk) then
			s0_axi_awready <= '0';
			s0_axi_wready  <= '0';
			if aresetn = '0' then
				s0_axi_bresp  <= b"00";
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
                                                        p_local(1 to 32) <= s0_axi_wdata;
                                
                                                        elsif (s0_axi_awaddr >= x"004"
                                                        and s0_axi_awaddr <= x"007") then
                                                        s0_axi_bresp <= b"00"; -- OKAY
                                                        p_local(33 to 64) <= s0_axi_wdata;
                                        
                                                        elsif (s0_axi_awaddr >= x"008"
                                                        and s0_axi_awaddr <= x"00B") then
                                                        s0_axi_bresp <= b"00"; -- OKAY
                                                        c_local(1 to 32) <= s0_axi_wdata;
                                        
                                                        elsif (s0_axi_awaddr >= x"00C"
                                                        and s0_axi_awaddr <= x"00F") then
                                                        s0_axi_bresp <= b"00"; -- OKAY
                                                        c_local(33 to 64) <= s0_axi_wdata;

                                                        elsif (s0_axi_awaddr >= x"010"
                                                        and s0_axi_awaddr <= x"013") then
                                                        s0_axi_bresp <= b"00"; -- OKAY
                                                        k0_local(1 to 32) <= s0_axi_wdata;
                                                        crack_wvalid<='0';
                                        
                                                        elsif (s0_axi_awaddr >= x"014"
                                                        and s0_axi_awaddr <= x"017") then
                                                        s0_axi_bresp <= b"00"; -- OKAY
                                                        k0_local(33 to 56) <= s0_axi_wdata(31 downto 8);
-- je ne prends pas les derniers bits de wdata
                                                        crack_wvalid<='1';
                                        
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
	end process;

process(aclk)
		
	begin
		if rising_edge(aclk) then
			s0_axi_arready <= '0';
			if aresetn = '0' then
				state_r       <= idle;
				s0_axi_rresp  <= b"00";
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
                                                        s0_axi_rdata <= p(1 to 32);

                                                        elsif (s0_axi_araddr >= x"003"
                                                        and s0_axi_araddr <= x"007") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= p(33 to 64);

                                                        elsif (s0_axi_araddr >= x"008"
                                                        and s0_axi_araddr <= x"00B") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= c(1 to 32);                                       

                                                        elsif (s0_axi_araddr >= x"00C"
                                                        and s0_axi_araddr <= x"00F") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= c(33 to 64);

                                                        elsif (s0_axi_araddr >= x"010"
                                                        and s0_axi_araddr <= x"013") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= k0(1 to 32);  

                                                        elsif (s0_axi_araddr >= x"014"
                                                        and s0_axi_araddr <= x"017") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= "00000000"& k0(33 to 56);

                                                        elsif (s0_axi_araddr >= x"018"
                                                        and s0_axi_araddr <= x"01B") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= k(1 to 32);
                                                        crack_rvalid<='1';
                                                        
                                                        elsif (s0_axi_araddr >= x"01C"
                                                        and s0_axi_araddr <= x"01F") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <="00000000"& k(33 to 56);
                                                        crack_rvalid<='0';

                                                        elsif (s0_axi_araddr >= x"020"
                                                        and s0_axi_araddr <= x"023") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= k1(1 to 32);        

                                                        elsif (s0_axi_araddr >= x"024"
                                                        and s0_axi_araddr <= x"027") then
                                                        s0_axi_rresp <= b"00"; -- OKAY
                                                        s0_axi_rdata <= "00000000"& k1(33 to 56);                                        

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
	end process;


process
   begin

     if rising_edge(aclk) then
       if aresetn='0' then
        p <= (others =>'0');
	c  <= (others =>'0');
	k0  <= (others =>'0');
        k  <= (others =>'0');
	k1  <= (others =>'0');

       else
         p <= p_local;
         c  <= c_local;
         k0  <= k0_local;
         k<=k0;
         case state_cr is
           when running => 
             k<=kg(k); -- k vaudra k+1 seulement a la fin du process
             if c=des(p,k, true) then
               k1 <= k;
               -- IRQ A REGARDER
             elsif crack_wvalid = '1' and crack_rvalid='1' then
               state_cr <= running;
             elsif crack_wvalid='0' or crack_rvalid='0' then
                state_cr <= frozen;
             end if;
           when frozen =>
              if crack_wvalid = '1' and crack_rvalid='1' then
                state_cr <= running;
              else
                state_cr <= frozen;
              end if;
         end case;
        end if;
     end if;

end process;
   
end architecture rtl;
