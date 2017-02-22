library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity pixel_counter is
    port(
        clk : in std_logic;
        hs : in std_logic;
        vs : in std_logic;
        vde : in std_logic;
        pixel_x : out std_logic_vector(15 downto 0);
        pixel_y : out std_logic_vector(15 downto 0)
    );
end pixel_counter;


architecture Behavioral of pixel_counter is

    signal x : unsigned(15 downto 0);
    signal y : unsigned(15 downto 0);

    signal hs_prev : std_logic;
    signal vs_prev : std_logic;
    signal hs_rising : std_logic;
    signal vs_rising : std_logic;
    signal visible_row : std_logic;

begin

    process(clk) is
    begin
        if (rising_edge(clk)) then
            hs_prev <= hs;
            vs_prev <= vs;  

            if (vs_rising = '1') then
                -- Clear Y count on vsync
                y <= (others => '0');
            elsif (hs_rising = '1') then
                -- Clear X count on hsync
                x <= (others => '0');
                -- Clear visible row flag on hsync
                visible_row <= '0';
                if (visible_row = '1') then
                    -- Increment Y count on hsync only if a row was shown
                    y <= y + 1;
                end if;
            elsif (vde = '1') then
                -- Increment the X count on visible video
                x <= x + 1;
                -- Raise visible row flag
                visible_row <= '1';
            end if;

        end if;
    end process;
    
    -- Edge Detection
    hs_rising <= '1' when (hs_prev = '0' and HS = '1') else '0';
    vs_rising <= '1' when (vs_prev = '0' and VS = '1') else '0';
    
    -- Pixel Output
    pixel_x <= std_logic_vector(x);
    pixel_y <= std_logic_vector(y);
    
end Behavioral;