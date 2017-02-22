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
    --reg in
     slv_reg0 : in std_logic_vector(31 downto 0);  
     slv_reg1 : in std_logic_vector(31 downto 0);  
     slv_reg2 : in std_logic_vector(31 downto 0);  
     slv_reg3 : in std_logic_vector(31 downto 0);  
     slv_reg4 : in std_logic_vector(31 downto 0);
     slv_reg5 : in std_logic_vector(31 downto 0);  
     slv_reg6 : in std_logic_vector(31 downto 0);  
     slv_reg7 : in std_logic_vector(31 downto 0);    
     
    --reg out
    slv_reg0out : out std_logic_vector(31 downto 0);  
    slv_reg1out : out std_logic_vector(31 downto 0);  
    slv_reg2out : out std_logic_vector(31 downto 0);  
    slv_reg3out : out std_logic_vector(31 downto 0);  
    slv_reg4out : out std_logic_vector(31 downto 0);
    slv_reg5out : out std_logic_vector(31 downto 0);  
    slv_reg6out : out std_logic_vector(31 downto 0);  
    slv_reg7out : out std_logic_vector(31 downto 0);
    
    --Bus Clock
    CLK : in std_logic;
    --Video
    RGB_IN_I : in std_logic_vector(23 downto 0); -- Parallel video data (required)
    VDE_IN_I : in std_logic; -- Active video Flag (optional)
    HB_IN_I : in std_logic; -- Horizontal blanking signal (optional)
    VB_IN_I : in std_logic; -- Vertical blanking signal (optional)
    HS_IN_I : in std_logic; -- Horizontal sync signal (optional)
    VS_IN_I : in std_logic; -- Veritcal sync signal (optional)
    ID_IN_I : in std_logic; -- Field ID (optional)
    --  additional ports here
    RGB_IN_O : out std_logic_vector(23 downto 0); -- Parallel video data (required)
    VDE_IN_O : out std_logic; -- Active video Flag (optional)
    HB_IN_O : out std_logic; -- Horizontal blanking signal (optional)
    VB_IN_O : out std_logic; -- Vertical blanking signal (optional)
    HS_IN_O : out std_logic; -- Horizontal sync signal (optional)
    VS_IN_O : out std_logic; -- Veritcal sync signal (optional)
    ID_IN_O : out std_logic; -- Field ID (optional)
    
    PIXEL_CLK_IN : in std_logic;
    
    X_Cord : in std_logic_vector(15 downto 0);
    Y_Cord : in std_logic_vector(15 downto 0)

);
end Video_Box;

architecture Behavioral of Video_Box is

    signal x,x1,x2 : unsigned(15 downto 0);
    signal y,y1,y2 : unsigned(15 downto 0);

begin
    
    x <= unsigned(x_cord);
    y <= unsigned(y_cord);
	x1 <= unsigned(slv_reg0(15 downto 0));
	x2 <= unsigned(slv_reg1(15 downto 0));
	y1 <= unsigned(slv_reg2(15 downto 0));
	y2 <= unsigned(slv_reg3(15 downto 0));


    RGB_IN_O 	<= (others => '0') when VDE_IN_I = '0' else
                   x"FF0000" when (y = y1) else
                   x"00FF00" when (y = y2) else
                   x"0000FF" when (x = x1) else
                   x"FF00FF" when (x = x2) else
                   RGB_IN_I; 
                   
    VDE_IN_O	<= VDE_IN_I;
    HB_IN_O		<= HB_IN_I;
    VB_IN_O		<= VB_IN_I;
    HS_IN_O		<= HS_IN_I;
    VS_IN_O		<= VS_IN_I;
    ID_IN_O		<= ID_IN_I;

    slv_reg0out <= slv_reg0;
    slv_reg1out <= slv_reg1;
    slv_reg2out <= slv_reg2;
    slv_reg3out <= slv_reg3;
    slv_reg4out <= slv_reg4;
    slv_reg5out <= slv_reg5;
    slv_reg6out <= slv_reg6;
    slv_reg7out <= slv_reg7;

end Behavioral;
