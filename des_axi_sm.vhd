library ieee;
use ieee.std_logic_1164.all;
--library unisim;
--use unisim.vcomponents.all;

entity sim is
  port (
    s0_axi_arready : out std_ulogic;
    s0_axi_awready : out std_ulogic;
    s0_axi_wready : out std_ulogic;
    s0_axi_rdata : out std_ulogic;
    s0_axi_rresp : out std_ulogic;
    s0_axi_rvalid : out std_ulogic;
    s0_axi_bresp : out std_ulogic_vector(1 downto 0);
    s0_axi_bvalid : out std_ulogic;
    led : out std_ulogic_vector(3 downto 0);
    irq : out std_ulogic
    );
end entity sim;

architecture rtl of sim is

-- signal instanciation

  aclk : std_ulogic;
  aresetn : std_ulogic;
  s0_axi_araddr : std_ulogic_vector(11 downto 0);
  s0_axi_arvalid : std_ulogic;
  s0_axi_awaddr : std_ulogic_vector(11 downto 0);
  s0_axi_awvalid : std_ulogic;
  s0_axi_wdata : std_ulogic_vector(31 downto 0);
  s0_axi_wstrb : std_ulogic_vector(3 downto 0);
  s0_axi_wvalid : std_ulogic;
  s0_axi_rready : std_ulogic;
  s0_axi_bready : std_ulogic;
  

-- axi instanciation 

  axi : entity work.axi(rtl)
    port map (
      aclk => aclk,
      aresetn => aresetn,
      s0_axi_araddr => s0_axi_araddr,
      s0_axi_arvalid => s0_axi_arvalid,
      s0_axi_arvalid => s0_axi_arvalid,
      s0_axi_awaddr => s0_axi_awaddr,
      s0_axi_awvalid => s0_axi_awvalid,
      s0_axi_awready => s0_axi_awready,
      s0_axi_wready => s0_axi_wready,
      s0_axi_wstrb   => s0_axi_wstrb,
      s0_axi_wvalid  => s0_axi_wvalid,
      s0_axi_bready  => s0_axi_bready,
      s0_axi_arready => s0_axi_arready,
      s0_axi_rdata   => s0_axi_rdata,
      s0_axi_rresp   => s0_axi_rresp,
      s0_axi_rvalid  => s0_axi_rvalid,
      s0_axi_wdata  => s0_axi_wdata,
      s0_axi_bresp   => s0_axi_bresp,
      s0_axi_bvalid  => s0_axi_bvalid,
      data           => data,
      led            => led
      );
  

  -- clock generation
  process
  begin
    aclk <= '0';
    wait for 1 ns;
    aclk <= '1';
    wait for 1 ns;
  end process;

  
process(aclk)
variable seed1: positive := 1;
variable seed2: positive := 1;
variable rnd:   real;
begin
  ---- RESET AND ENABLE TESTING ____
  -- Testing sresetn
  sresetn <= '0';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  sresetn <= '1';
  wait until rising_edge(aclk);
  -- Testing enable
  enable <= '0';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  enable <= '1';
  wait until rising_edge(aclk);
end process;

process(aclk)
  --Testing writing (k0, p, c)

  s0_axi_bready <='1';
  s0_axi_awvalid <= '1';
  s0_axi_walid <='1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_awaddr <=x"000";
  s0_axi_wdata <= x"f0f0f0f0";
  s0_axi_wdata <= x"f0f0f0f0";
  s0_axi_awvalid <= '0';
  s0_axi_walid <='0';
  
  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;

  
  
  s0_axi_awvalid <= '1';
  s0_axi_walid <='1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_awaddr <=x"008";
  s0_axi_wdata <= x"0b6a2cd8";
  s0_axi_wdata <= x"d51bb869";
  s0_axi_awvalid <= '0';
  s0_axi_walid <='0';
  s0_bready <='0';
  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;

  
  s0_axi_awvalid <= '1';
  s0_axi_walid <='1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  s0_bready <='1';
  so_axi_awaddr <=x"00f";
  s0_axi_wdata <= x"0000000";
  s0_axi_wdata <= x"0000000";
  s0_axi_awvalid <= '0';
  s0_axi_walid <='0';  
end process;




process 
  --Testing reading (k0, p , c, k, k1)
  s0_axi_arvalid <= '1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"000";
  s0_axi_arvalid <= '0';
  s0_axi_arready <='0';
  s0_axi_rvalid <='0';

  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;

  
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"004";
  s0_axi_arready <='0';
  s0_axi_rvalid <='0';
  s0_axi_arvalid <= '0';

  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;

  
  s0_axi_arvalid <= '1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"008";
  s0_axi_arvalid <= '0';
  
  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;

  s0_axi_arvalid <= '1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"00b";
  s0_axi_arvalid <= '0';

  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;
  
  s0_axi_arvalid <= '0';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"00c";
  s0_axi_arvalid <= '0';


  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;
  
  s0_axi_arvalid <= '1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"010";
  s0_axi_arvalid <= '0';

  for i in 1 to 20 loop
    wait until rising_edge(aclk);
  end loop;
  
  s0_axi_arvalid <= '1';
  for i in 1 to 10 loop
    wait until rising_edge(aclk);
  end loop;
  so_axi_araddr <=x"014";
  s0_axi_arvalid <= '0';

  -- faire k et k1

end process;

-- KEY RESEARCH
process
begin
  while irq /='1' ..
