----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Andrew Wilson
-- 
-- Create Date: 02/10/2017 11:07:04 AM
-- Design Name: RGB filter
-- Module Name: Video_Box - Behavioral
-- Project Name: 
-- Tool Versions: Vivado 2016.3 
-- Description: This design is for a partial bitstream to be programmed
-- on Brigham Young Univeristy's Video Base Design.
-- This filter allows the edit of the RGB values of the pixel through
-- through user registers
-- 
-- Revision:
-- Revision 1.0
-- 
----------------------------------------------------------------------------------


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
    -- Users to add parameters here
    
    -- User parameters ends
    -- Do not modify the parameters beyond this line
    
    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH    : integer    := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH    : integer    := 11
);
port (
    S_AXI_ARESETN : in std_logic;
    slv_reg_wren : in std_logic;
    slv_reg_rden : in std_logic;
    S_AXI_WSTRB    : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    axi_awaddr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_WDATA    : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    axi_araddr    : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    reg_data_out    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    
    --Bus Clock
    S_AXI_ACLK : in std_logic;
    --Video
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
    
    X_Coord : in std_logic_vector(15 downto 0);
    Y_Coord : in std_logic_vector(15 downto 0)

);
end Video_Box;

--Begin RGB Control architecture
architecture Behavioral of Video_Box is

	--Create Red, Blue, Green signals that contain the actual Red,
		--Blue, and Green signals
	signal red, blue, green : std_logic_vector(7 downto 0);
	--Create the register controlled Red, Green, and Blue signals
	signal lred, lblue, lgreen : std_logic_vector(7 downto 0);
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH-ADDR_LSB-1;
	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

	signal RGB_IN_reg, RGB_OUT_reg: std_logic_vector(23 downto 0):= (others=>'0');
	signal X_Coord_reg,Y_Coord_reg : std_logic_vector(15 downto 0):= (others=>'0');
	signal VDE_IN_reg,VDE_OUT_reg,HS_IN_reg,HS_OUT_reg,VS_IN_reg,VS_OUT_reg : std_logic := '0';
	signal USER_LOGIC : std_logic_vector(23 downto 0);
	
	
begin

	--the user can edit the rgb values here

	-- Get the original Red, Green, and Blue signals
	red <= RGB_IN_reg(23 downto 16);
	green <= RGB_IN_reg(15 downto 8);
	blue <= RGB_IN_reg(7 downto 0);
	
	-- Set the Red value to the register0 value if it is less than the original red value
	-- Otherwise, keep at the original red value
	lred <= slv_reg0(7 downto 0) when slv_reg0(7 downto 0) < red else red;
	
	-- Set the Green value to the register0 value if it is less than the original green value
	-- Otherwise, keep at the original green value
	lgreen <= slv_reg1(7 downto 0) when slv_reg1(7 downto 0) < green else green;
	
	-- Set the Blue value to the register0 value if it is less than the original blue value
	-- Otherwise, keep at the original blue value
	lblue <= slv_reg2(7 downto 0) when slv_reg2(7 downto 0) < blue else blue;
	
	-- Concatenate the new RED, Green, Blue values and route them out
	USER_LOGIC 	<= lred&lgreen&lblue;





	-- Just pass through all of the video signals
	RGB_OUT 	<= RGB_OUT_reg;
	VDE_OUT		<= VDE_OUT_reg;

	HS_OUT		<= HS_OUT_reg;
	VS_OUT		<= VS_OUT_reg;


	
process(PIXEL_CLK) is
    begin
        if (rising_edge (PIXEL_CLK)) then
            -- Video Input Signals
            RGB_IN_reg <= RGB_IN;
            X_Coord_reg <= X_Coord;
            Y_Coord_reg  <= Y_Coord;
            VDE_IN_reg  <= VDE_IN;
            HS_IN_reg  <= HS_IN;
            VS_IN_reg  <= VS_IN;
            -- Video Output Signals
            RGB_OUT_reg  <= USER_LOGIC;
            VDE_OUT_reg  <= VDE_IN_reg;
            HS_OUT_reg  <= HS_IN_reg;
            VS_OUT_reg  <= VS_IN_reg;
 
         end if;
    end process;


	
	-- Route the registers through
process (S_AXI_ACLK)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
begin
  if rising_edge(S_AXI_ACLK) then 
	if S_AXI_ARESETN = '0' then
	  slv_reg0 <= (others => '0');
	  slv_reg1 <= (others => '0');
	  slv_reg2 <= (others => '0');
	  
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
		  when others =>
			slv_reg0 <= slv_reg0;
			slv_reg1 <= slv_reg1;
			slv_reg2 <= slv_reg2;
		end case;
	  end if;
	end if;
  end if;                   
end process; 
	
process (slv_reg0, slv_reg1, slv_reg2, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
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
	  when others =>
		reg_data_out  <= (others => '0');
	end case;
end process;

end Behavioral;
--End RGB Control architecture