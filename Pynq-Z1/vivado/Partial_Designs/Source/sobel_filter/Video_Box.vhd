----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Alexander West
-- 
-- Create Date: 03/23/2017
-- Design Name: Sobel filter
-- Module Name: Video_Box - Behavioral
-- Project Name: 
-- Tool Versions: Vivado 2016.3 
-- Description: This design is for a partial bitstream to be programmed
-- on Brigham Young Univeristy's Video Base Design.
--
-- This filter applies the Sobel operator.
-- 
-- Revision:
-- Revision 1.0
-- 
----------------------------------------------------------------------------------

library work;
use work.filter_lib.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Video_Box is
    generic (
        C_S_AXI_DATA_WIDTH : integer := 32; -- Width of S_AXI data bus
        C_S_AXI_ADDR_WIDTH : integer := 11  -- Width of S_AXI address bus
    );
    port (
        -- AXI interface ports
        S_AXI_ARESETN : in std_logic;                                           -- Reset the registers
        slv_reg_wren  : in std_logic;                                           -- Write enable
        slv_reg_rden  : in std_logic;                                           -- Read enable
        S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0); -- Selector for writing individual bytes
        axi_awaddr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);     -- Write Address
        S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);     -- Write Data
        axi_araddr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);     -- Read Address
        reg_data_out  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);    -- Read Data
        
        -- Bus Clock
        S_AXI_ACLK : in std_logic;

        -- Pixel Clock
        PIXEL_CLK : in std_logic;

        -- Video Input
        RGB_IN : in std_logic_vector(23 downto 0); -- Parallel video data (required)
        VDE_IN : in std_logic; -- Active video Flag (optional)    
        HS_IN : in std_logic;  -- Horizontal sync signal (optional)
        VS_IN : in std_logic;  -- Veritcal sync signal (optional)
                
        X_Coord : in std_logic_vector(15 downto 0);
        Y_Coord : in std_logic_vector(15 downto 0);

        -- Video Output
        RGB_OUT : out std_logic_vector(23 downto 0); -- Parallel video data (required)
        VDE_OUT : out std_logic; -- Active video Flag (optional)
        HS_OUT : out std_logic;  -- Horizontal sync signal (optional)
        VS_OUT : out std_logic   -- Veritcal sync signal (optional)
        
    );
end Video_Box;


architecture Behavioral of Video_Box is
    -- Bus Constants
 	constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH/32) + 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH - ADDR_LSB - 1;
	
	-- Video Interface
    signal vid_in_reg, vid_mod, vid_out_reg : rgb_interface_t;
    signal X_Coord_reg, Y_Coord_reg : std_logic_vector(15 downto 0):= (others=>'0');
	
	-- Control/Output Registers
	signal slv_reg0, slv_reg1, slv_reg2, slv_reg3 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4, slv_reg5, slv_reg6, slv_reg7 : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	
begin
	
	-- I/O Buffering
    process(PIXEL_CLK) is
    begin
        if (rising_edge (PIXEL_CLK)) then
            -- Video Input Signals
            vid_in_reg.rgb <= RGB_IN;
            vid_in_reg.vde <= VDE_IN;
            vid_in_reg.hs <= HS_IN;
            vid_in_reg.vs <= VS_IN;
            
            X_Coord_reg <= X_Coord;
            Y_Coord_reg <= Y_Coord;
            
            -- Video Output Signals
            vid_out_reg <= vid_mod;
         end if;
    end process;

	-- Module Output
	RGB_OUT <= vid_out_reg.rgb;
	VDE_OUT	<= vid_out_reg.vde;
	HS_OUT	<= vid_out_reg.hs;
	VS_OUT	<= vid_out_reg.vs;
	
	-- Filter Module
    filter_a : entity work.sobel_filter(Behavioral)
        port map (
            -- Video Interface
            vid_i => vid_in_reg,
            vid_o => vid_mod,
            -- Pixel Coordinates
            x_position => X_Coord_reg,
            -- y_in => Y_Coord_reg,
            
            -- Register Inputs
            threshold => slv_reg0(7 downto 0),
            sensitivity => slv_reg1(3 downto 0),
            invert => slv_reg2(0),
            split_line => slv_reg3(15 downto 0),
            rotoscope => slv_reg4(0),
            
            -- Reference Clock
            PIXEL_CLK => PIXEL_CLK
        );
	
	-- Register Input Logic       
    process (S_AXI_ACLK)
        variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          slv_reg0 <= (others => '0');
          slv_reg1 <= (others => '0');
          slv_reg2 <= (others => '0');
          slv_reg3 <= (others => '0');
          slv_reg4 <= (others => '0');
          slv_reg5 <= (others => '0');
          slv_reg6 <= (others => '0');
          slv_reg7 <= (others => '0');
        else
          loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
          if (slv_reg_wren = '1') then
            case loc_addr is
              when b"000000000" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 0
                    slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000001" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 1
                    slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000010" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 2
                    slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000011" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 3
                    slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000100" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 4
                    slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000101" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 5
                    slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000110" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 6
                    slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when b"000000111" =>
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 7
                    slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              when others =>
                slv_reg0 <= slv_reg0;
                slv_reg1 <= slv_reg1;
                slv_reg2 <= slv_reg2;
                slv_reg3 <= slv_reg3;
                slv_reg4 <= slv_reg4;
                slv_reg5 <= slv_reg5;
                slv_reg6 <= slv_reg6;
                slv_reg7 <= slv_reg7;
            end case;
          end if;
        end if;
      end if;                   
    end process; 
    
    -- Register Output Logic
    process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
        variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
        -- Address decoding for reading registers
        loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        case loc_addr is
          when b"000000000" =>
            reg_data_out <= slv_reg0;
          when b"000000001" =>
            reg_data_out <= slv_reg1;
          when b"000000010" =>
            reg_data_out <= slv_reg2;
          when b"000000011" =>
            reg_data_out <= slv_reg3;
          when b"000000100" =>
            reg_data_out <= slv_reg4;
          when b"000000101" =>
            reg_data_out <= slv_reg5;
          when b"000000110" =>
            reg_data_out <= slv_reg6;
          when b"000000111" =>
            reg_data_out <= slv_reg7;
          when others =>
            reg_data_out  <= (others => '0');
        end case;
    end process;

end Behavioral;
--End Sobel filter architecture
