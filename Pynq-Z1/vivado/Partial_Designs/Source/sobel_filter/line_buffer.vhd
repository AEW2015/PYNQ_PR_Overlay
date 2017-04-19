----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2017 01:41:12 PM
-- Design Name: 
-- Module Name: line_buffer - inferred
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

--use IEEE.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity line_buffer is
    generic (
        LENGTH : natural
    );
    port ( 
        CLK : in STD_LOGIC;
        en : in STD_LOGIC;
        index : in STD_LOGIC_VECTOR(log2ceil(LENGTH) - 1 downto 0);
        d_in : in STD_LOGIC_VECTOR;
        d_out : out STD_LOGIC_VECTOR
    );
end line_buffer;

architecture inferred of line_buffer is
    type RAM_array is array(natural range <>) of std_logic_vector(d_in'range);
    signal line_buffer : RAM_array(LENGTH - 1 downto 0);
begin
    process(CLK)
    begin
        if rising_edge(CLK) then
            if en = '1' then
                line_buffer( to_integer(unsigned(index)) ) <= d_in;
                d_out <= line_buffer( to_integer(unsigned(index)) );
            end if;
        end if;
    end process;
end inferred;
