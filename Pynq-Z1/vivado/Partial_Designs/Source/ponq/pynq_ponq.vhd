----------------------------------------------------------------------------------
-- Company: Brigham Young University
-- Engineer: Alexander West
-- 
-- Create Date: 03/27/2017 02:41:10 PM
-- Design Name: 
-- Module Name: pynq_ponq - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.filter_lib.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pynq_ponq is
    generic(
        NUM_BALLS : natural
    );
    port(        
        -- Video Interface
        vid_i : in rgb_interface_t;
        vid_o : out rgb_interface_t;
        -- Pixel Coordinates
        x_pos : in std_logic_vector(15 downto 0);
        y_pos : in std_logic_vector(15 downto 0);        
        -- Register Inputs
        --ball_in : ball_t;
        balls : ball_vector_t(NUM_BALLS-1 downto 0);
        -- Reference Clock
        PIXEL_CLK : std_logic
    );
end pynq_ponq;

architecture Behavioral of pynq_ponq is
    signal ball_active : std_logic_vector(NUM_BALLS downto 0);
    signal any_ball_active : std_logic;
    signal temp_rgb : std_logic_vector(23 downto 0);
begin
    -- Bounds check for each ball
    for_balls:
    for n in 0 to NUM_BALLS - 1 generate
        ball_active(n) 
            <= '1' 
                when ((unsigned(x_pos) - balls(n).x) < balls(n).w) 
                and ((unsigned(y_pos) - balls(n).y) < balls(n).h)
            else '0';
    end generate;
    
    -- Or reduce
    any_ball_active <= or_reduce(ball_active);
    
    -- Priority Decoder
    process(balls, ball_active, vid_i)
    begin
        temp_rgb <= vid_i.rgb;
        for ball in balls'range loop
            if (ball_active(ball) = '1') then
                temp_rgb <= balls(ball).color;
            end if;
        end loop;
    end process;    
    
    -- Display logic
--    temp_rgb 
--        <= (others=>'1') 
--            when (any_ball_active = '1') 
--            and (vid_i.vde = '1')
--        else vid_i.rgb;

    -- Outputs
    vid_o.vde <= vid_i.vde;
    vid_o.hs <= vid_i.hs;
    vid_o.vs <= vid_i.vs;
    vid_o.rgb <= temp_rgb;
end Behavioral;
