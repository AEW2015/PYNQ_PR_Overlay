----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Andrew Wilson
-- 
-- Create Date: 02/10/2017 11:07:04 AM
-- Design Name: Box Overlay Filter 2
-- Module Name: Video_Box - Behavioral
-- Project Name: 
-- Tool Versions: Vivado 2016.3 
-- Description: This design is for a partial bitstream to be programmed
-- on Brigham Young Univeristy's Video Base Design.
-- This filter passes the video signals from input to output except at
-- locations defined by user registers, where instead it will draw lines.
-- This filter draws lines on the image that form a box where the line 
-- thickness is defined by a user register.
-- 
-- Revision:
-- Revision 1.0
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Video_Box is
generic (
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

-- Begin Box architecture
architecture Behavioral of Video_Box is

	-- X location signals
    signal x,x1,x2 : signed(15 downto 0);
	-- Y location signals
    signal y,y1,y2,diff : signed(15 downto 0);
	
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH-ADDR_LSB-1;
	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	
	signal RGB_IN_reg, RGB_OUT_reg: std_logic_vector(23 downto 0):= (others=>'0');
	signal X_Coord_reg,Y_Coord_reg : std_logic_vector(15 downto 0):= (others=>'0');
	signal VDE_IN_reg,VDE_OUT_reg,HS_IN_reg,HS_OUT_reg,VS_IN_reg,VS_OUT_reg : std_logic := '0';
	signal USER_LOGIC : std_logic_vector(23 downto 0);

begin
    
	-- Get the pixel's x and y coordinates
    x <= signed(X_Coord);
    y <= signed(Y_Coord);
	
	-- Get the left and right x coordinates from the registers
	x1 <= signed(slv_reg0(15 downto 0));
	x2 <= signed(slv_reg1(15 downto 0));
	-- Get the top and bottom y coordinates from the registers
	y1 <= signed(slv_reg2(15 downto 0));
	y2 <= signed(slv_reg3(15 downto 0));
	
	-- Get the size of the lines desired by reading register 4
	diff <= signed(slv_reg4(15 downto 0));


	-- Create a variable width pixel box at the register defined locations
	-- When the display isn't being written to, write 0's
    USER_LOGIC 	<= (others => '0') when VDE_IN_reg = '0' else
				-- if the y value is greater than y1-diff and less than y1+diff,
				-- then make change the color to the line's color
                   x"FF0000" when (y > (y1-diff) and y < (y1+diff)) else
				-- if the y value is greater than y2-diff and less than y2+diff,
				-- then make change the color to the line's color
                   x"00FF00" when (y > (y2-diff) and y < (y2+diff)) else
				-- if the x value is greater than x1-diff and less than x1+diff,
				-- then make change the color to the line's color
                   x"0000FF" when (x > (x1-diff) and x < (x1+diff)) else
				-- if the x value is greater than x2-diff and less than x2+diff,
				-- then make change the color to the line's color
                   x"FF00FF" when (x > (x2-diff) and x < (x2+diff)) else
				-- Otherwise, pass the RGB value straight through
                   RGB_IN_reg; 
                   
	-- Pass the other video signals straight through
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
		  when others =>
			slv_reg0 <= slv_reg0;
			slv_reg1 <= slv_reg1;
			slv_reg2 <= slv_reg2;
			slv_reg3 <= slv_reg3;
			slv_reg4 <= slv_reg4;
		end case;
	  end if;
	end if;
  end if;                   
end process; 
	
process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
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
	  when others =>
		reg_data_out  <= (others => '0');
	end case;
	
end process;
end Behavioral;
-- End Box architecture