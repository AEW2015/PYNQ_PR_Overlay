----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Alexander West
-- 
-- Create Date: 03/23/2017
-- Design Name: PYNQ PONQ
-- Module Name: Video_Box - Behavioral
-- Project Name: 
-- Tool Versions: Vivado 2016.3 
-- Description: This design is for a partial bitstream to be programmed
-- on Brigham Young Univeristy's Video Base Design.
--
-- This handles display logic for the Pynq Ponq game.
-- 
-- Revision:
-- Revision 1.0
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.filter_lib.all;

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
        RGB_IN : in std_logic_vector(23 downto 0); -- Parallel video data
        VDE_IN : in std_logic;                     -- Active video Flag
        HS_IN : in std_logic;                      -- Horizontal sync signal
        VS_IN : in std_logic;                      -- Veritcal sync signal
        
        -- Input Coordinates
        X_Coord : in std_logic_vector(15 downto 0);
        Y_Coord : in std_logic_vector(15 downto 0);

        -- Video Output
        RGB_OUT : out std_logic_vector(23 downto 0); -- Parallel video data
        VDE_OUT : out std_logic;                     -- Active video Flag
        HS_OUT : out std_logic;                      -- Horizontal sync signal
        VS_OUT : out std_logic                       -- Veritcal sync signal
    );
end Video_Box;

architecture PYNQ_PONQ of Video_Box is
    -- Bus Constants
 	constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH/32) + 1;
	constant OPT_MEM_ADDR_BITS : integer := C_S_AXI_ADDR_WIDTH - ADDR_LSB - 1;
	
	-- Video Interface
    signal vid_in_reg, vid_mod, vid_out_reg : rgb_interface_t;
    signal X_Coord_reg, Y_Coord_reg : std_logic_vector(15 downto 0):= (others=>'0');
	
	-- Balls
	constant NUM_BALLS : natural := 12; -- 16 is too many
	signal balls_temp : ball_vector_t(NUM_BALLS-1 downto 0);
	
	-- Registers
	constant NUM_REG : natural := NUM_BALLS * 5;
	subtype reg_t is std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	type reg_array_t is array(natural range <>) of reg_t;
	signal slv_reg : reg_array_t(NUM_REG-1 downto 0);	
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
            -- Coordinates
            X_Coord_reg <= X_Coord;
            Y_Coord_reg <= Y_Coord;
            -- Video Output Signals
            vid_out_reg <= vid_mod;
         end if;
    end process;
	
	-- Convert Registers into ball_t
	ball_in:
	for ball in 0 to NUM_BALLS-1 generate
	   balls_temp(ball).x <= unsigned(slv_reg(ball*5 + 0)(ball_t.x'range));
	   balls_temp(ball).y <= unsigned(slv_reg(ball*5 + 1)(ball_t.y'range));
	   balls_temp(ball).w <= unsigned(slv_reg(ball*5 + 2)(ball_t.w'range));
	   balls_temp(ball).h <= unsigned(slv_reg(ball*5 + 3)(ball_t.h'range));
	   balls_temp(ball).color <=      slv_reg(ball*5 + 4)(ball_t.color'range);
	end generate;
	
	-- Filter Module
    PONQ : entity work.pynq_ponq(Behavioral)
        generic map (
            NUM_BALLS => NUM_BALLS
        )
        port map (
            -- Video Interface
            vid_i => vid_in_reg,
            vid_o => vid_mod,
            -- Pixel Coordinates
            x_pos => X_Coord_reg,
            y_pos => Y_Coord_reg,
            -- Register Inputs
            balls => balls_temp,
            -- Reference Clock
            PIXEL_CLK => PIXEL_CLK
        );

	-- Module Output
	RGB_OUT <= vid_out_reg.rgb;
	VDE_OUT	<= vid_out_reg.vde;
	HS_OUT	<= vid_out_reg.hs;
	VS_OUT	<= vid_out_reg.vs;
	
-- Register Bus Logic
	-- Register Input Logic
	process (S_AXI_ACLK)
      variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0); 
    begin
      if rising_edge(S_AXI_ACLK) then 
        if S_AXI_ARESETN = '0' then
          slv_reg <= (others => (others => '0'));
        else
          loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
          -- Default Value
          slv_reg <= slv_reg;
          -- For each register
          --for reg in 0 to (NUM_REG-1) loop
            if (slv_reg_wren = '1') then
              --if ( loc_addr = std_logic_vector(to_unsigned(reg, ADDR_LSB + OPT_MEM_ADDR_BITS + 1)) ) then
              if ( unsigned(loc_addr) < NUM_REG ) then
                -- Respective byte enables are asserted as per write strobes
                for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                  if ( S_AXI_WSTRB(byte_index) = '1' ) then                   
                    slv_reg(to_integer(unsigned(loc_addr)))(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                  end if;
                end loop;
              --else
              --  slv_reg <= slv_reg;
              end if;
              --end if; -- loc_addr = reg 
            end if; -- slv_reg_wren = '1'
          --end loop; -- reg in 0 to (NUM_REG-1)
        end if; -- S_AXI_ARESETN = '0'
      end if; -- rising_edge(S_AXI_ACLK)                
    end process;
    
    -- Register Output Logic
    process (slv_reg, S_AXI_ARESETN, slv_reg_rden, axi_araddr)
        variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
        -- Address decoding for reading registers
        loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
--        -- Default data out
--        reg_data_out <= (others => '0');
--        for reg in 0 to (NUM_REG-1) loop
--          if ( unsigned(loc_addr) = to_unsigned(reg, ADDR_LSB + OPT_MEM_ADDR_BITS + 1) ) then
--            reg_data_out <= slv_reg(to_integer(unsigned(loc_addr)));
--          end if;
--        end loop;
        if unsigned(loc_addr) < NUM_REG then
            reg_data_out <= slv_reg(to_integer(unsigned(loc_addr)));
        else
            reg_data_out <= (others=>'0');
        end if;
        
    end process;

end PYNQ_PONQ;
--End Pynq Ponq Top-Level Module