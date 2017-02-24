----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2017 11:07:04 AM
-- Design Name: 
-- Module Name: Video_Box - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Video_Box is
port (
    -- Registers In
     slv_reg0 : in std_logic_vector(31 downto 0);  
     slv_reg1 : in std_logic_vector(31 downto 0);  
     slv_reg2 : in std_logic_vector(31 downto 0);  
     slv_reg3 : in std_logic_vector(31 downto 0);  
     slv_reg4 : in std_logic_vector(31 downto 0);
     slv_reg5 : in std_logic_vector(31 downto 0);  
     slv_reg6 : in std_logic_vector(31 downto 0);  
     slv_reg7 : in std_logic_vector(31 downto 0);    
     
    -- Registers Out
    slv_reg0out : out std_logic_vector(31 downto 0);  
    slv_reg1out : out std_logic_vector(31 downto 0);  
    slv_reg2out : out std_logic_vector(31 downto 0);  
    slv_reg3out : out std_logic_vector(31 downto 0);  
    slv_reg4out : out std_logic_vector(31 downto 0);
    slv_reg5out : out std_logic_vector(31 downto 0);  
    slv_reg6out : out std_logic_vector(31 downto 0);  
    slv_reg7out : out std_logic_vector(31 downto 0);
    
    -- Bus Clock
    CLK : in std_logic;
	
    -- Video Input Signals
    RGB_IN_I : in std_logic_vector(23 downto 0); -- Parallel video data (required)
    VDE_IN_I : in std_logic; -- Active video Flag (optional)
    HB_IN_I : in std_logic; -- Horizontal blanking signal (optional)
    VB_IN_I : in std_logic; -- Vertical blanking signal (optional)
    HS_IN_I : in std_logic; -- Horizontal sync signal (optional)
    VS_IN_I : in std_logic; -- Veritcal sync signal (optional)
    ID_IN_I : in std_logic; -- Field ID (optional)
    
	-- Video Output Signals
    RGB_IN_O : out std_logic_vector(23 downto 0); -- Parallel video data (required)
    VDE_IN_O : out std_logic; -- Active video Flag (optional)
    HB_IN_O : out std_logic; -- Horizontal blanking signal (optional)
    VB_IN_O : out std_logic; -- Vertical blanking signal (optional)
    HS_IN_O : out std_logic; -- Horizontal sync signal (optional)
    VS_IN_O : out std_logic; -- Veritcal sync signal (optional)
    ID_IN_O : out std_logic; -- Field ID (optional)

	-- Pixel Clock
    PIXEL_CLK_IN : in std_logic;
	
	-- Signals that give the x and y coordinates of the current pixel    
    X_Cord : in std_logic_vector(15 downto 0);
    Y_Cord : in std_logic_vector(15 downto 0)

);
end Video_Box;

-- Begin Box architecture
architecture Behavioral of Video_Box is

	-- X location signals
    signal x,x1,x2 : signed(15 downto 0);
	-- Y location signals
    signal y,y1,y2,diff : signed(15 downto 0);

begin
    
	-- Get the pixel's x and y coordinates
    x <= signed(x_cord);
    y <= signed(y_cord);
	
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
    RGB_IN_O 	<= (others => '0') when VDE_IN_I = '0' else
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
                   RGB_IN_I; 
                   
	-- Pass the other video signals straight through
    VDE_IN_O	<= VDE_IN_I;
    HB_IN_O		<= HB_IN_I;
    VB_IN_O		<= VB_IN_I;
    HS_IN_O		<= HS_IN_I;
    VS_IN_O		<= VS_IN_I;
    ID_IN_O		<= ID_IN_I;

	-- Pass the Register signals straight through
    slv_reg0out <= slv_reg0;
    slv_reg1out <= slv_reg1;
    slv_reg2out <= slv_reg2;
    slv_reg3out <= slv_reg3;
    slv_reg4out <= slv_reg4;
    slv_reg5out <= slv_reg5;
    slv_reg6out <= slv_reg6;
    slv_reg7out <= slv_reg7;

end Behavioral;
-- End Box architecture