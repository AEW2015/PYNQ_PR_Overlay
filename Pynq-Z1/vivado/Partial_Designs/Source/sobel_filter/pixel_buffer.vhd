----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2017 03:01:40 PM
-- Design Name: 
-- Module Name: pixel_buffer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library work;
use work.filter_lib.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_buffer is
    generic (
        WIDTH : natural := 3;
        HEIGHT : natural := 3;
        LINE_LENGTH : natural := 2048
    );
    port ( 
        -- Clock
        CLK : in std_logic;
        -- Inputs
        data_in : in pixel_t;
        vde_in : in std_logic; -- Active video Flag (optional)
        hs_in : in std_logic; -- Horizontal sync signal (optional)
        vs_in : in std_logic; -- Veritcal sync signal (optional)
        -- Outputs
        data_out : out pixel2d_t(WIDTH - 1 downto 0, HEIGHT - 1 downto 0);        
        vde_out : out std_logic; -- Active video Flag (optional)
        hs_out : out std_logic; -- Horizontal sync signal (optional)
        vs_out : out std_logic -- Veritcal sync signal (optional)
    );
end pixel_buffer;

architecture Behavioral of pixel_buffer is
    signal to_window : pixel_t;
    
    -- Indeces for the line buffers
    signal line_buffer_index, line_buffer_index_next : unsigned(log2ceil(LINE_LENGTH) - 1 downto 0);
    -- Window of pixels to be sent out
    signal window_reg, window_next : pixel2d_t(WIDTH - 1 downto 0, HEIGHT - 1 downto 0);
    
    -- Used to control shifting in the linebuffer    
    signal new_line, vde_prev, shift : std_logic;
    
begin
    -- To guarantee zero padding
    to_window <= data_in when vde_in = '1' else
                 (others=>'0');

-- Control logic for shifting stuff
    shift <= vde_in;

-- Falling-edge detector for the vde signal
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            vde_prev <= vde_in;
        end if;    
    end process;
 
    new_line <= '1' when (vde_prev = '1') and (vde_in = '0') else '0';

-- Counter for line_buffer_index
    process(CLK)
    begin
        if (rising_edge(CLK)) then
            line_buffer_index <= line_buffer_index_next;
			window_reg <= window_next;
        end if;    
    end process;

    -- Increment when shift is asserted, zero otherwise
    line_buffer_index_next <= (others=>'0') when (new_line = '1') else 
                              (line_buffer_index + 1) when (shift = '1')  else 
                              line_buffer_index;

-- LINEBUFFERS and WINDOW
	-- Generate linebuffers, and do reads/writes to the window
    if_linebuffers:
    if (HEIGHT > 1) generate -- Verify if this is necessary or not
        for_linebuffers:
        for row in 1 to HEIGHT - 1 generate
           line_x : entity work.line_buffer(inferred)
               generic map (
                   LENGTH => 2048
               )
               port map (
                   CLK => CLK,
                   en => shift,
                   index => std_logic_vector(line_buffer_index),
                   d_in => window_next(0, row - 1),
                   d_out => window_next(0, row)
               );                      
        end generate;
    end generate;
    
    -- Shift pixels around in the window 
    window_next(0,0) <= to_window when (shift = '1') else
                        window_reg(0, 0);
    rows:
    for row in 0 to (HEIGHT - 1) generate
        columns:                 
        for column in 0 to (WIDTH - 1) generate
            -- If not last column
            not_last_col:
            if column < (WIDTH - 1) generate
                -- Feed each pixel to the next reg in the row
                window_next(column + 1, row) <= window_reg(column, row) when (shift = '1') else
                                                window_reg(column + 1, row);
            end generate; -- if not last col
        end generate; -- for cols
    end generate; -- for rows

-- Outputs
    data_out <= window_reg;
    -- TODO: Delay these by an appropriate amount
    vde_out <= vde_in;
    hs_out  <= hs_in;
    vs_out  <= vs_in;

end Behavioral;
