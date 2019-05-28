library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.des_pkg.all;

use std.env.all;

entity des_axi_sim is
	port (
		s0_axi_arready: out std_ulogic;
		s0_axi_awready: out std_ulogic;
		s0_axi_wready:  out std_ulogic;
		s0_axi_rdata:   out std_ulogic_vector(31 downto 0);
		s0_axi_rresp:   out std_ulogic_vector(1 downto 0);
		s0_axi_rvalid:  out std_ulogic;
		s0_axi_bresp:   out std_ulogic_vector(1 downto 0);
		s0_axi_bvalid:  out std_ulogic;
		led:            out std_ulogic_vector(3 downto 0);
		irq:            out std_ulogic
	);
end entity des_axi_sim;

architecture rtl of des_axi_sim is

	signal aclk:           std_ulogic;
	signal aresetn:        std_ulogic;
	signal s0_axi_araddr:  std_ulogic_vector(11 downto 0);
	signal s0_axi_arvalid: std_ulogic;
	signal s0_axi_awaddr:  std_ulogic_vector(11 downto 0);
	signal s0_axi_awvalid: std_ulogic;
	signal s0_axi_wdata:   std_ulogic_vector(31 downto 0);
	signal s0_axi_wstrb:   std_ulogic_vector(3 downto 0);
	signal s0_axi_wvalid:  std_ulogic;
	signal s0_axi_rready:  std_ulogic;
	signal s0_axi_bready:  std_ulogic;

	procedure read_sim(signal aclk : std_ulogic;
					   addr : std_ulogic_vector(11 downto 0);
					   signal s0_axi_rready: out std_ulogic;
					   signal s0_axi_araddr: out std_ulogic_vector(11 downto 0);
					   signal s0_axi_arvalid: out std_ulogic) is
	begin
		s0_axi_rready  <= '0';
		s0_axi_araddr  <= addr;
		s0_axi_arvalid <= '1';
		wait until rising_edge(aclk); 
		s0_axi_arvalid <= '0';
		s0_axi_rready  <= '1';
	end read_sim;

	procedure write_sim(signal aclk : std_ulogic;
						addr : std_ulogic_vector(11 downto 0);
						data: w32;
						signal s0_axi_bready : out std_ulogic;
						signal s0_axi_awaddr : out std_ulogic_vector(11 downto 0);
						signal s0_axi_awvalid : out std_ulogic ;
						signal s0_axi_wvalid : out std_ulogic;
						signal s0_axi_wdata : out w32) is
	begin
		s0_axi_bready  <= '0';
		S0_axi_awaddr  <= addr;
		s0_axi_awvalid <= '1';
		s0_axi_wvalid  <= '1';
		s0_axi_wdata   <= data;
		wait until rising_edge(aclk);
		s0_axi_awvalid <= '0';
		s0_axi_wvalid  <= '0';
		s0_axi_bready  <= '1';
	end write_sim;

begin 

	-----------------------
	-- AXI instanciation --
	-----------------------
	axi : entity work.axi(rtl)
		port map (
			aclk           => aclk,
			aresetn        => aresetn,
			s0_axi_araddr  => s0_axi_araddr,
			s0_axi_arvalid => s0_axi_arvalid,
			s0_axi_awaddr  => s0_axi_awaddr,
			s0_axi_awvalid => s0_axi_awvalid,
			s0_axi_awready => s0_axi_awready,
			s0_axi_wready  => s0_axi_wready,
			s0_axi_wstrb   => s0_axi_wstrb,
			s0_axi_wvalid  => s0_axi_wvalid,
			s0_axi_bready  => s0_axi_bready,
			s0_axi_arready => s0_axi_arready,
			s0_axi_rdata   => s0_axi_rdata,
			s0_axi_rresp   => s0_axi_rresp,
			s0_axi_rvalid  => s0_axi_rvalid,
			s0_axi_wdata   => s0_axi_wdata,
			s0_axi_bresp   => s0_axi_bresp,
			s0_axi_bvalid  => s0_axi_bvalid,
			s0_axi_rready  => s0_axi_rready,
			irq            => irq,
			led            => led
		);

	-------------------
	-- Clock process --
	-------------------
	process
	begin
		aclk <= '0';
		wait for 1 ns;
		aclk <= '1';
		wait for 1 ns;
	end process;

	------------------------
	-- Simulation process --
	------------------------
	process
	begin
		aresetn <= '1';
		wait until rising_edge(aclk);
		aresetn <= '0';
		wait until rising_edge(aclk);
		aresetn <='1';

		---------------------------------------
		-- Testing read and write on p and c --
		---------------------------------------
		-- Writing p --
		write_sim(aclk, x"000", x"f0f0f0f0", s0_axi_bready, s0_axi_awaddr, s0_axi_awvalid, s0_axi_wvalid, s0_axi_wdata);
		wait until rising_edge(aclk);
		write_sim(aclk, x"004", x"f0f0f0f0", s0_axi_bready, s0_axi_awaddr, s0_axi_awvalid, s0_axi_wvalid, s0_axi_wdata);
		wait until rising_edge(aclk);
		-- Writing c --
		write_sim(aclk, x"008", x"d51bb869", s0_axi_bready, s0_axi_awaddr, s0_axi_awvalid, s0_axi_wvalid, s0_axi_wdata);
		wait until rising_edge(aclk);
		write_sim(aclk, x"00C", x"0b6a2cd8", s0_axi_bready, s0_axi_awaddr, s0_axi_awvalid, s0_axi_wvalid, s0_axi_wdata);
		wait until rising_edge(aclk);
		--
		-- Reading p --
		read_sim(aclk, x"000", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);
		read_sim(aclk, x"004", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);
		-- Reading c --
		read_sim(aclk, x"008", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);
		read_sim(aclk, x"00C", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);


		-----------------------------------
		-- Writing k0 and search the key --
		-----------------------------------
		-- Writing k0 --
		write_sim(aclk, x"010", x"00000000", s0_axi_bready, s0_axi_awaddr, s0_axi_awvalid, s0_axi_wvalid, s0_axi_wdata);
		wait until rising_edge(aclk);
		write_sim(aclk, x"014", x"00000000", s0_axi_bready, s0_axi_awaddr, s0_axi_awvalid, s0_axi_wvalid, s0_axi_wdata);  
		wait until rising_edge(aclk);

		-- Reading k0 to make sure --
		read_sim(aclk, x"010", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);
		read_sim(aclk, x"014", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);

		while irq /='1' loop
			-- Reading the current key continuously --
			read_sim(aclk, x"018", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
			wait until rising_edge(aclk);
			read_sim(aclk, x"01C", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
			wait until rising_edge(aclk);
		end loop;

		-- Reading k1 if found --
		read_sim(aclk, x"020", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);
		read_sim(aclk, x"024", s0_axi_rready, s0_axi_araddr, s0_axi_arvalid);
		wait until rising_edge(aclk);

		finish;

	end process;
end  rtl;

-- vim: set ts=4 sw=4 tw=90 noet :
