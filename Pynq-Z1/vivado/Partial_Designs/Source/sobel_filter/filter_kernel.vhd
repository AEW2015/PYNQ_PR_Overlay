----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2017 03:53:11 PM
-- Design Name: 
-- Module Name: filter_kernel - Combinational
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

entity filter_kernel is
    generic (
        WIDTH : natural;
        HEIGHT : natural;
        kernel : kernel_matrix_t
    );
    port (
        data_in : in pixel2d_t(WIDTH - 1 downto 0, HEIGHT - 1 downto 0);
        data_out : out signed
    );
end filter_kernel;

architecture Combinational of filter_kernel is
begin
    process(data_in) -- Apply the two sobel operators
        variable tmp : signed(21 downto 0);
    begin 
        tmp := (others=>'0');
        for row in 0 to WIDTH - 1 loop
            for col in 0 to HEIGHT - 1 loop
                tmp := tmp + signed(data_in(row,col)) * kernel(row,col);
            end loop;
        end loop;
        data_out <= tmp;
    end process;

end Combinational;
