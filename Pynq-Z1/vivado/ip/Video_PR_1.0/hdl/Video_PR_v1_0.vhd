library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Video_PR_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 11
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line
        RGB_IN : in std_logic_vector(23 downto 0); -- Parallel video data (required)
        VDE_IN : in std_logic; -- Active video Flag (optional)
        HS_IN : in std_logic; -- Horizontal sync signal (optional)
        VS_IN : in std_logic; -- Veritcal sync signal (optional)
       
        --  additional ports here
        RGB_OUT : out std_logic_vector(23 downto 0); -- Parallel video data (required)
        VDE_OUT : out std_logic; -- Active video Flag (optional)
     
        HS_OUT : out std_logic; -- Horizontal sync signal (optional)
        VS_OUT : out std_logic; -- Veritcal sync signal (optional)
        
        
        PIXEL_CLK : in std_logic;

		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk	: in std_logic;
		s_axi_aresetn	: in std_logic;
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		s_axi_awvalid	: in std_logic;
		s_axi_awready	: out std_logic;
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid	: in std_logic;
		s_axi_wready	: out std_logic;
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		s_axi_bvalid	: out std_logic;
		s_axi_bready	: in std_logic;
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		s_axi_arvalid	: in std_logic;
		s_axi_arready	: out std_logic;
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		s_axi_rvalid	: out std_logic;
		s_axi_rready	: in std_logic
	);
end Video_PR_v1_0;

architecture arch_imp of Video_PR_v1_0 is
        ATTRIBUTE X_INTERFACE_INFO : STRING;
ATTRIBUTE X_INTERFACE_INFO of RGB_IN: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN DATA";
ATTRIBUTE X_INTERFACE_INFO of VDE_IN: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN ACTIVE_VIDEO";

ATTRIBUTE X_INTERFACE_INFO of HS_IN: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN HSYNC";
ATTRIBUTE X_INTERFACE_INFO of VS_IN: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN VSYNC";



ATTRIBUTE X_INTERFACE_INFO of RGB_OUT: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_OUT DATA";
ATTRIBUTE X_INTERFACE_INFO of VDE_OUT: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_OUT ACTIVE_VIDEO";

ATTRIBUTE X_INTERFACE_INFO of HS_OUT: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_OUT HSYNC";
ATTRIBUTE X_INTERFACE_INFO of VS_OUT: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_OUT VSYNC";



	-- component declaration
	component Video_PR_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 11
		);
		port (
				         -- Users to add ports here
        RGB_IN : in std_logic_vector(23 downto 0); -- Parallel video data (required)
         VDE_IN : in std_logic; -- Active video Flag (optional)
         HS_IN : in std_logic; -- Horizontal sync signal (optional)
         VS_IN : in std_logic; -- Veritcal sync signal (optional)
        
         --  additional ports here
         RGB_OUT : out std_logic_vector(23 downto 0); -- Parallel video data (required)
         VDE_OUT : out std_logic; -- Active video Flag (optional)
      
         HS_OUT : out std_logic; -- Horizontal sync signal (optional)
         VS_OUT : out std_logic; -- Veritcal sync signal (optional)
         
         
         PIXEL_CLK : in std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component Video_PR_v1_0_S_AXI;

begin


-- Instantiation of Axi Bus Interface S_AXI
Video_PR_v1_0_S_AXI_inst : Video_PR_v1_0_S_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S_AXI_ADDR_WIDTH
	)
	port map (
		 --video signals
            RGB_IN => RGB_IN,
            VDE_IN  => VDE_IN,

            HS_IN  => HS_IN,
            VS_IN  => VS_IN,

            --  additional ports here
            RGB_OUT  => RGB_OUT,
            VDE_OUT  => VDE_OUT,

            HS_OUT  => HS_OUT,
            VS_OUT  => VS_OUT,

            PIXEL_CLK  => PIXEL_CLK,
            
		S_AXI_ACLK	=> s_axi_aclk,
		S_AXI_ARESETN	=> s_axi_aresetn,
		S_AXI_AWADDR	=> s_axi_awaddr,
		S_AXI_AWPROT	=> s_axi_awprot,
		S_AXI_AWVALID	=> s_axi_awvalid,
		S_AXI_AWREADY	=> s_axi_awready,
		S_AXI_WDATA	=> s_axi_wdata,
		S_AXI_WSTRB	=> s_axi_wstrb,
		S_AXI_WVALID	=> s_axi_wvalid,
		S_AXI_WREADY	=> s_axi_wready,
		S_AXI_BRESP	=> s_axi_bresp,
		S_AXI_BVALID	=> s_axi_bvalid,
		S_AXI_BREADY	=> s_axi_bready,
		S_AXI_ARADDR	=> s_axi_araddr,
		S_AXI_ARPROT	=> s_axi_arprot,
		S_AXI_ARVALID	=> s_axi_arvalid,
		S_AXI_ARREADY	=> s_axi_arready,
		S_AXI_RDATA	=> s_axi_rdata,
		S_AXI_RRESP	=> s_axi_rresp,
		S_AXI_RVALID	=> s_axi_rvalid,
		S_AXI_RREADY	=> s_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
