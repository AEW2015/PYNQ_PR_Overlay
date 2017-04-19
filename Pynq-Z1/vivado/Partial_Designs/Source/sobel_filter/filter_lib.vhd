----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2017 03:15:15 PM
-- Design Name: 
-- Module Name: filter_lib - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package filter_lib is
    -- User-defined types
    subtype pixel_t is std_logic_vector(9 downto 0);
    type pixel_vector_t is array(natural range <>) of pixel_t;
    type pixel2d_t is array(natural range <>, natural range <>) of pixel_t;
    
    type kernel_matrix_t is array(natural range <>, natural range <>) of integer;
    
    type rgb_interface_t is record
        RGB : std_logic_vector(23 downto 0); -- Parallel video data
        VDE : std_logic; -- Active video Flag
        HS : std_logic; -- Horizontal sync signal
        VS : std_logic; -- Veritcal sync signal
    end record rgb_interface_t;

    -- Useful functions
    function log2ceil (L: POSITIVE) return NATURAL;

end filter_lib;

package body filter_lib is
    -- Useful functions
    function log2ceil (L: POSITIVE) return NATURAL is
      variable i : natural;
    begin
       i := 0;  
       while (2**i < L) and i < 31 loop
          i := i + 1;
       end loop;
       return i;
    end log2ceil;
    
end filter_lib;