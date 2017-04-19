----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2017 02:26:58 PM
-- Design Name: 
-- Module Name: blur - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sobel_filter is
    port (
        vid_i : in rgb_interface_t;
        vid_o : out rgb_interface_t;
        
		x_position : in std_logic_vector(15 downto 0);
		
        threshold : in std_logic_vector(7 downto 0);
        sensitivity : in std_logic_vector(3 downto 0);
        invert : in std_logic;
		split_line : in std_logic_vector(15 downto 0);
		rotoscope : in std_logic;
		
        PIXEL_CLK : in std_logic
    );
end sobel_filter;

architecture Behavioral of sobel_filter is
    -- We need to convert the image to grayscale before processing it.
    signal pixel_in : pixel_t;
	
    -- Size of the filter
    constant FILTER_WIDTH : natural := 3;
    constant FILTER_HEIGHT : natural := 3;

    -- Output of the linebuffer / Input to the filters
    signal window : pixel2d_t(FILTER_WIDTH - 1 downto 0, FILTER_HEIGHT - 1 downto 0);
    
    -- Kernels for our filters
    constant sobel_x_kernel : kernel_matrix_t(FILTER_WIDTH - 1 downto 0, FILTER_HEIGHT - 1 downto 0) := (
        (-1, 0, 1),
        (-2, 0, 2),
        (-1, 0, 1)
    );
    constant sobel_y_kernel : kernel_matrix_t(FILTER_WIDTH - 1 downto 0, FILTER_HEIGHT - 1 downto 0) := (
        (-1,-2,-1),
        ( 0, 0, 0),
        ( 1, 2, 1)
    );
    
    -- Results of the two filter kernels
    signal sobel_x, sobel_y : signed(21 downto 0) := (others => '0');
    
    -- Post-filter computations and results (thresholding, truncation, saturation, inversion, etc.)
    signal sobel_mag, sobel_shift : signed(21 downto 0);
    signal sobel_trunc, sobel_sat, sobel_inv : std_logic_vector(7 downto 0);
    signal roto_rgb, roto_combined, rgb_buf, rgb_buf_reg : std_logic_vector(23 downto 0);
    
    -- Buffered output
    signal vid_buf, vid_buf_reg, vid_out : rgb_interface_t;
begin
    -- Convert input to grayscale	
    pixel_in <= 
        std_logic_vector(
                resize(unsigned( vid_i.RGB(23 downto 16) ), 10) + 
                resize(unsigned( vid_i.RGB(15 downto  8) ), 10) +
                resize(unsigned( vid_i.RGB( 7 downto  0) ), 10)
        );
    
-- Parameterizable pixel buffer
    pixel_buf: entity work.pixel_buffer(Behavioral)
        generic map (
            WIDTH => FILTER_WIDTH,
            HEIGHT => FILTER_HEIGHT,
            LINE_LENGTH => 2048
        )
        port map ( 
            -- Clock
            CLK => PIXEL_CLK,
            -- Inputs
            data_in => pixel_in,
            vde_in => vid_i.vde,
            hs_in  => vid_i.hs,
            vs_in  => vid_i.vs,
			
            -- Outputs
            data_out => window,
            vde_out => vid_buf.vde,
            hs_out  => vid_buf.hs,
            vs_out  => vid_buf.vs
        );
    vid_buf.rgb <= vid_i.rgb;

-- Filter kernels
    sobel_x_filter : entity work.filter_kernel(Combinational)
        generic map (
            WIDTH => FILTER_WIDTH,
            HEIGHT => FILTER_HEIGHT,
            kernel => sobel_x_kernel
        )
        port map (
            data_in => window,
            data_out => sobel_x
        );

    sobel_y_filter : entity work.filter_kernel(Combinational)
        generic map (
            WIDTH => FILTER_WIDTH,
            HEIGHT => FILTER_HEIGHT,
            kernel => sobel_y_kernel
        )
        port map (
            data_in => window,
            data_out => sobel_y
        );

-- Process the outputs of the filters    
    -- Approximate magnitude
    sobel_mag <= abs(sobel_x) + abs(sobel_y);
    -- Move the radix point
    sobel_shift <= sobel_mag srl to_integer(unsigned(sensitivity));
    -- Truncate
    sobel_trunc <= std_logic_vector(sobel_shift(7 downto 0));    
    -- Threshold and Saturate
    sobel_sat <= (others=>'0') when unsigned(sobel_shift) < unsigned(threshold) else
                 (others=>'1') when unsigned(sobel_shift) > 255 else
                 sobel_trunc;
    -- Invert
    sobel_inv <= sobel_sat when invert = '0' else
                 not(sobel_sat);
    -- Rotoscoping Logic
    -- Give the color a nice "palettized" look
    roto_rgb <= vid_i.RGB(23 downto 20) & vid_i.RGB(23 downto 20) -- R
              & vid_i.RGB(15 downto 12) & vid_i.RGB(15 downto 12) -- G
              & vid_i.RGB(7 downto 4)   & vid_i.RGB(7 downto 4);  -- B
    roto_combined <= (sobel_inv & sobel_inv & sobel_inv) when unsigned(sobel_shift) > 255 else
                     roto_rgb;
    -- Select Rotoscope
    rgb_buf <= roto_combined when (rotoscope = '1') else
               (sobel_inv & sobel_inv & sobel_inv);
-- Buffer stage
    process(PIXEL_CLK)
    begin
       if (rising_edge(PIXEL_CLK)) then
           -- Buffer stage
           rgb_buf_reg <= rgb_buf;
           vid_buf_reg <= vid_buf;
           
           -- Do splitscreen and buffer the output
           if (unsigned(x_position) < unsigned(split_line)) then
               vid_out.rgb <= rgb_buf_reg;
           else
               vid_out.rgb <= vid_buf_reg.rgb;
           end if;
           vid_out.vde <= vid_buf_reg.vde;
           vid_out.hs <= vid_buf_reg.hs;
           vid_out.vs <= vid_buf_reg.vs;
       end if;  
    end process;     
	
-- Output
    vid_o <= vid_out;

end Behavioral;
