----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Andrew Wilson
-- 
-- Create Date: 03/17/2017 11:07:04 AM
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
-- Revision 1.1
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
	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5 :std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

	signal RGB_IN_reg, RGB_OUT_reg: std_logic_vector(23 downto 0):= (others=>'0');
	signal X_Coord_reg,Y_Coord_reg : std_logic_vector(15 downto 0):= (others=>'0');
	signal VDE_IN_reg,VDE_OUT_reg,HS_IN_reg,HS_OUT_reg,VS_IN_reg,VS_OUT_reg : std_logic := '0';
	--signal USER_LOGIC : std_logic_vector(23 downto 0);
	
	constant N : integer := 16;
    
    component blk_mem_gen_0 IS
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clkb : IN STD_LOGIC;
        enb : IN STD_LOGIC;
        addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END component blk_mem_gen_0;
	
	type rgb_array is array(0 to 255) of std_logic_vector(23 downto 0);
     signal color_array : rgb_array := (
    x"000000", x"800000", x"008000", x"808000", x"000080", x"800080", x"008080", x"C0C0C0", x"808080", x"FF0000", x"00FF00", x"FFFF00", x"0000FF", x"FF00FF", x"00FFFF", x"FFFFFF", 
    x"000000", x"00005F", x"000087", x"0000AF", x"0000D7", x"0000FF", x"005F00", x"005F5F", x"005F87", x"005FAF", x"005FD7", x"005FFF", x"008700", x"00875F", x"008787", x"0087AF", 
    x"0087D7", x"0087FF", x"00AF00", x"00AF5F", x"00AF87", x"00AFAF", x"00AFD7", x"00AFFF", x"00D700", x"00D75F", x"00D787", x"00D7AF", x"00D7D7", x"00D7FF", x"00FF00", x"00FF5F", 
    x"00FF87", x"00FFAF", x"00FFD7", x"00FFFF", x"5F0000", x"5F005F", x"5F0087", x"5F00AF", x"5F00D7", x"5F00FF", x"5F5F00", x"5F5F5F", x"5F5F87", x"5F5FAF", x"5F5FD7", x"5F5FFF", 
    x"5F8700", x"5F875F", x"5F8787", x"5F87AF", x"5F87D7", x"5F87FF", x"5FAF00", x"5FAF5F", x"5FAF87", x"5FAFAF", x"5FAFD7", x"5FAFFF", x"5FD700", x"5FD75F", x"5FD787", x"5FD7AF", 
    x"5FD7D7", x"5FD7FF", x"5FFF00", x"5FFF5F", x"5FFF87", x"5FFFAF", x"5FFFD7", x"5FFFFF", x"870000", x"87005F", x"870087", x"8700AF", x"8700D7", x"8700FF", x"875F00", x"875F5F", 
    x"875F87", x"875FAF", x"875FD7", x"875FFF", x"878700", x"87875F", x"878787", x"8787AF", x"8787D7", x"8787FF", x"87AF00", x"87AF5F", x"87AF87", x"87AFAF", x"87AFD7", x"87AFFF", 
    x"87D700", x"87D75F", x"87D787", x"87D7AF", x"87D7D7", x"87D7FF", x"87FF00", x"87FF5F", x"87FF87", x"87FFAF", x"87FFD7", x"87FFFF", x"AF0000", x"AF005F", x"AF0087", x"AF00AF", 
    x"AF00D7", x"AF00FF", x"AF5F00", x"AF5F5F", x"AF5F87", x"AF5FAF", x"AF5FD7", x"AF5FFF", x"AF8700", x"AF875F", x"AF8787", x"AF87AF", x"AF87D7", x"AF87FF", x"AFAF00", x"AFAF5F", 
    x"AFAF87", x"AFAFAF", x"AFAFD7", x"AFAFFF", x"AFD700", x"AFD75F", x"AFD787", x"AFD7AF", x"AFD7D7", x"AFD7FF", x"AFFF00", x"AFFF5F", x"AFFF87", x"AFFFAF", x"AFFFD7", x"AFFFFF", 
    x"D70000", x"D7005F", x"D70087", x"D700AF", x"D700D7", x"D700FF", x"D75F00", x"D75F5F", x"D75F87", x"D75FAF", x"D75FD7", x"D75FFF", x"D78700", x"D7875F", x"D78787", x"D787AF", 
    x"D787D7", x"D787FF", x"D7AF00", x"D7AF5F", x"D7AF87", x"D7AFAF", x"D7AFD7", x"D7AFFF", x"D7D700", x"D7D75F", x"D7D787", x"D7D7AF", x"D7D7D7", x"D7D7FF", x"D7FF00", x"D7FF5F", 
    x"D7FF87", x"D7FFAF", x"D7FFD7", x"D7FFFF", x"FF0000", x"FF005F", x"FF0087", x"FF00AF", x"FF00D7", x"FF00FF", x"FF5F00", x"FF5F5F", x"FF5F87", x"FF5FAF", x"FF5FD7", x"FF5FFF", 
    x"FF8700", x"FF875F", x"FF8787", x"FF87AF", x"FF87D7", x"FF87FF", x"FFAF00", x"FFAF5F", x"FFAF87", x"FFAFAF", x"FFAFD7", x"FFAFFF", x"FFD700", x"FFD75F", x"FFD787", x"FFD7AF", 
    x"FFD7D7", x"FFD7FF", x"FFFF00", x"FFFF5F", x"FFFF87", x"FFFFAF", x"FFFFD7", x"FFFFFF", x"080808", x"121212", x"1C1C1C", x"262626", x"303030", x"3A3A3A", x"444444", x"4E4E4E", 
    x"585858", x"606060", x"666666", x"767676", x"808080", x"8A8A8A", x"949494", x"9E9E9E", x"A8A8A8", x"B2B2B2", x"BCBCBC", x"C6C6C6", x"D0D0D0", x"DADADA", x"E4E4E4", x"EEEEEE"
    );
    
    signal RGB_IN_reg0, RGB_IN_reg1 : std_logic_vector(23 downto 0);
    signal VDE_IN_reg0, VDE_IN_reg1 : std_logic;
    signal HB_IN_reg0, HB_IN_reg1 : std_logic;
    signal VB_IN_reg0, VB_IN_reg1 : std_logic;
    signal HS_IN_reg0, HS_IN_reg1 : std_logic;
    signal VS_IN_reg0, VS_IN_reg1 : std_logic;
    signal ID_IN_reg0, ID_IN_reg1 : std_logic;
     
    signal rgb_next : std_logic_vector(23 downto 0);
    signal use_image : std_logic;
    signal color_index, color_index_next : unsigned(7 downto 0);
    signal image_index, image_index_next : unsigned(N-1 downto 0);
    signal pixel : std_logic_vector(23 downto 0);
    
    signal int_X_Coord_reg0, int_X_Coord_reg1 : unsigned(15 downto 0);
    signal int_Y_Coord_reg0, int_Y_Coord_reg1 : unsigned(15 downto 0);
    signal int_X_Orig_reg0, int_X_Orig_reg1 : unsigned(15 downto 0);
    signal int_Y_Orig_reg0, int_Y_Orig_reg1 : unsigned(15 downto 0);
    
    signal int_X_Coord : unsigned(15 downto 0);
    signal int_Y_Coord : unsigned(15 downto 0);
    signal int_X_Orig : unsigned(15 downto 0);
    signal int_Y_Orig : unsigned(15 downto 0);
    signal img_width : unsigned(15 downto 0);
    signal img_height : unsigned(15 downto 0);
    
    --signal din, dout : std_logic_vector(23 downto 0);
    signal we, rden, wren : std_logic;
    signal dout0, dout1 : std_logic_vector(7 downto 0);
    signal rdaddr, wraddr : std_logic_vector(N-1 downto 0);
    signal din : std_logic_vector(7 downto 0);
	
begin

	--the user can edit the rgb values here

	process(PIXEL_CLK)
    begin
        if(PIXEL_CLK'event and PIXEL_CLK='1') then
            RGB_IN_reg0 <= RGB_IN_reg;
            VDE_IN_reg0 <= VDE_IN_reg;
            HS_IN_reg0 <= HS_IN_reg;
            VS_IN_reg0 <= VS_IN_reg;
            
            int_X_Coord_reg0 <= unsigned(X_Coord_reg);
            int_Y_Coord_reg0 <= unsigned(Y_Coord_reg);
            
            int_X_Orig_reg0 <= unsigned(slv_reg0(15 downto 0));
            int_Y_Orig_reg0 <= unsigned(slv_reg1(15 downto 0));
            
            RGB_IN_reg1 <= RGB_IN_reg0;
            VDE_IN_reg1 <= VDE_IN_reg0;
            HS_IN_reg1 <= HS_IN_reg0;
            VS_IN_reg1 <= VS_IN_reg0;
            
            int_X_Coord_reg1 <= int_X_Coord_reg0;
            int_Y_Coord_reg1 <= int_Y_Coord_reg0;
            
            int_X_Orig_reg1 <= int_X_Coord_reg0;
            int_Y_Orig_reg1 <= int_Y_Coord_reg0;
            
            image_index <= image_index_next;
                
        end if;
    end process;
    
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
            RGB_OUT_reg  <= rgb_next;
            VDE_OUT_reg  <= VDE_IN_reg1;
            HS_OUT_reg  <= HS_IN_reg1;
            VS_OUT_reg  <= VS_IN_reg1;
 
         end if;
    end process;
    
--    process(S_AXI_ACLK) is
--    begin
--        if(rising_edge(S_AXI_ACLK)) then
            wraddr <= slv_reg5(23 downto 8);
            din <= slv_reg5(7 downto 0);
            wren <= slv_reg_wren;
--        end if;
--    end process;

	bram0: blk_mem_gen_0
    port map(
        
        clka => S_AXI_ACLK,
        ena => wren,
        wea(0) => we,
        addra => wraddr,
        dina => din,
        clkb => PIXEL_CLK,
        enb => rden,
        addrb => rdaddr,
        doutb => dout0
    );

    we <= '1';
    rden <= '1';
    rdaddr <= std_logic_vector(image_index);
    
	-- Add user logic here
	int_X_Coord <= int_X_Coord_reg1;
	int_Y_Coord <= int_Y_Coord_reg1;
	int_X_Orig <= unsigned(slv_reg0(15 downto 0));
	int_Y_Orig <= unsigned(slv_reg1(15 downto 0));
	img_width <= unsigned(slv_reg2(15 downto 0));
	img_height <= unsigned(slv_reg3(15 downto 0));
	
	use_image <= '1' when int_X_Coord >= int_X_Orig and 
				int_X_Coord < int_X_Orig + img_width and
				int_Y_Coord >= int_Y_Orig and 
				int_Y_Coord < int_Y_Orig + img_height
				  else '0';
				  
	image_index_next <= (others => '0') when unsigned(X_Coord_reg) = int_X_Orig and unsigned(Y_Coord_reg) = int_Y_Orig and VDE_IN_reg='1'  else
	                   image_index + 1 when use_image = '1' and VDE_IN_reg='1' else
	                   image_index;    
    
    --color_index <= unsigned(dout0) when image_index < 40960 else unsigned(dout1);
    color_index <= unsigned(dout0);
    pixel <= color_array(to_integer(color_index));
	
	rgb_next <= pixel when use_image = '1' and std_logic_vector(color_index) /= slv_reg4(7 downto 0) else RGB_IN_reg1;
    

	-- Just pass through all of the video signals
	RGB_OUT 	<= RGB_OUT_reg;
	VDE_OUT		<= VDE_OUT_reg;

	HS_OUT		<= HS_OUT_reg;
	VS_OUT		<= VS_OUT_reg;

	-- Route the registers through
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
                -- slave registor 2
                slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when b"000000100" =>
            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
              if ( S_AXI_WSTRB(byte_index) = '1' ) then
                -- Respective byte enables are asserted as per write strobes                   
                -- slave registor 2
                slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
          when b"000000101" =>
            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
              if ( S_AXI_WSTRB(byte_index) = '1' ) then
                -- Respective byte enables are asserted as per write strobes                   
                -- slave registor 2
                slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
              end if;
            end loop;
		  when others =>
			slv_reg0 <= slv_reg0;
			slv_reg1 <= slv_reg1;
			slv_reg2 <= slv_reg2;
			slv_reg3 <= slv_reg3;
			slv_reg5 <= slv_reg4;
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
	  when b"000000011" =>
        reg_data_out <= slv_reg3;
      when b"000000100" =>
        reg_data_out <= slv_reg4;
	  when others =>
		reg_data_out  <= (others => '0');
	end case;
end process;

end Behavioral;
--End RGB Control architecture