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
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
                 -- Users to add ports here
          RGB_IN_I : in std_logic_vector(23 downto 0); -- Parallel video data (required)
          VDE_IN_I : in std_logic; -- Active video Flag (optional)
          HB_IN_I : in std_logic; -- Horizontal blanking signal (optional)
          VB_IN_I : in std_logic; -- Vertical blanking signal (optional)
          HS_IN_I : in std_logic; -- Horizontal sync signal (optional)
          VS_IN_I : in std_logic; -- Veritcal sync signal (optional)
          ID_IN_I : in std_logic; -- Field ID (optional)
          --  additional ports here
          RGB_IN_O : out std_logic_vector(23 downto 0); -- Parallel video data (required)
          VDE_IN_O : out std_logic; -- Active video Flag (optional)
          HB_IN_O : out std_logic; -- Horizontal blanking signal (optional)
          VB_IN_O : out std_logic; -- Vertical blanking signal (optional)
          HS_IN_O : out std_logic; -- Horizontal sync signal (optional)
          VS_IN_O : out std_logic; -- Veritcal sync signal (optional)
          ID_IN_O : out std_logic; -- Field ID (optional)
          
          PIXEL_CLK_IN : in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


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
        ATTRIBUTE X_INTERFACE_INFO of RGB_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I DATA";
        ATTRIBUTE X_INTERFACE_INFO of VDE_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I ACTIVE_VIDEO";
        ATTRIBUTE X_INTERFACE_INFO of HB_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I HBLANK";
        ATTRIBUTE X_INTERFACE_INFO of VB_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I VBLANK";
        ATTRIBUTE X_INTERFACE_INFO of HS_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I HSYNC";
        ATTRIBUTE X_INTERFACE_INFO of VS_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I VSYNC";
        ATTRIBUTE X_INTERFACE_INFO of ID_IN_I: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_I FIELD";
        
        
        ATTRIBUTE X_INTERFACE_INFO of RGB_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O DATA";
        ATTRIBUTE X_INTERFACE_INFO of VDE_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O ACTIVE_VIDEO";
        ATTRIBUTE X_INTERFACE_INFO of HB_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O HBLANK";
        ATTRIBUTE X_INTERFACE_INFO of VB_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O VBLANK";
        ATTRIBUTE X_INTERFACE_INFO of HS_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O HSYNC";
        ATTRIBUTE X_INTERFACE_INFO of VS_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O VSYNC";
        ATTRIBUTE X_INTERFACE_INFO of ID_IN_O: SIGNAL is "xilinx.com:interface:vid_io:1.0 RGB_IN_O FIELD";



	-- component declaration
	component Video_PR_v1_0_S_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		         -- Users to add ports here
          RGB_IN_I : in std_logic_vector(23 downto 0); -- Parallel video data (required)
          VDE_IN_I : in std_logic; -- Active video Flag (optional)
          HB_IN_I : in std_logic; -- Horizontal blanking signal (optional)
          VB_IN_I : in std_logic; -- Vertical blanking signal (optional)
          HS_IN_I : in std_logic; -- Horizontal sync signal (optional)
          VS_IN_I : in std_logic; -- Veritcal sync signal (optional)
          ID_IN_I : in std_logic; -- Field ID (optional)
          --  additional ports here
          RGB_IN_O : out std_logic_vector(23 downto 0); -- Parallel video data (required)
          VDE_IN_O : out std_logic; -- Active video Flag (optional)
          HB_IN_O : out std_logic; -- Horizontal blanking signal (optional)
          VB_IN_O : out std_logic; -- Vertical blanking signal (optional)
          HS_IN_O : out std_logic; -- Horizontal sync signal (optional)
          VS_IN_O : out std_logic; -- Veritcal sync signal (optional)
          ID_IN_O : out std_logic; -- Field ID (optional)
          
          PIXEL_CLK_IN : in std_logic;
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
         RGB_IN_I => RGB_IN_I,
         VDE_IN_I  => VDE_IN_I,
         HB_IN_I  => HB_IN_I,
         VB_IN_I  => VB_IN_I,
         HS_IN_I  => HS_IN_I,
         VS_IN_I  => VS_IN_I,
         ID_IN_I  => ID_IN_I,
         --  additional ports here
         RGB_IN_O  => RGB_IN_O,
         VDE_IN_O  => VDE_IN_O,
         HB_IN_O  => HB_IN_O,
         VB_IN_O  => VB_IN_O,
         HS_IN_O  => HS_IN_O,
         VS_IN_O  => VS_IN_O,
         ID_IN_O  => ID_IN_O,
         PIXEL_CLK_IN  => PIXEL_CLK_IN,
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
