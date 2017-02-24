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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Video_Box is
port (

    -- Register in
     slv_reg0 : in std_logic_vector(31 downto 0);  
     slv_reg1 : in std_logic_vector(31 downto 0);  
     slv_reg2 : in std_logic_vector(31 downto 0);  
     slv_reg3 : in std_logic_vector(31 downto 0);  
     slv_reg4 : in std_logic_vector(31 downto 0);
     slv_reg5 : in std_logic_vector(31 downto 0);  
     slv_reg6 : in std_logic_vector(31 downto 0);  
     slv_reg7 : in std_logic_vector(31 downto 0);    
     
    -- Register out
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
    
	--Pixel Clock
    PIXEL_CLK_IN : in std_logic;
    
	--Signals that give the x and y coordinates of the current pixel
    X_Cord : in std_logic_vector(15 downto 0);
    Y_Cord : in std_logic_vector(15 downto 0)

);
end Video_Box;

--Begin RGB Control architecture
architecture Behavioral of Video_Box is

	--Create Red, Blue, Green signals that contain the actual Red,
		--Blue, and Green signals
	signal red, blue, green : std_logic_vector(7 downto 0);
	--Create the register controlled Red, Green, and Blue signals
	signal lred, lblue, lgreen : std_logic_vector(7 downto 0);
	
begin

	-- Get the original Red, Green, and Blue signals
	red <= RGB_IN_I(23 downto 16);
	green <= RGB_IN_I(15 downto 8);
	blue <= RGB_IN_I(7 downto 0);
	
	-- Set the Red value to the register0 value if it is less than the original red value
	-- Otherwise, keep at the original red value
	lred <= slv_reg0(7 downto 0) when slv_reg0(7 downto 0) < red else red;
	
	-- Set the Green value to the register0 value if it is less than the original green value
	-- Otherwise, keep at the original green value
	lgreen <= slv_reg1(7 downto 0) when slv_reg1(7 downto 0) < green else green;
	
	-- Set the Blue value to the register0 value if it is less than the original blue value
	-- Otherwise, keep at the original blue value
	lblue <= slv_reg2(7 downto 0) when slv_reg2(7 downto 0) < blue else blue;
	
	-- Concatenate the new RED, Green, Blue values and route them out
	RGB_IN_O 	<= lred&lgreen&lblue;
	
	-- Route the other video signals through
	VDE_IN_O	<= VDE_IN_I;
	HB_IN_O		<= HB_IN_I;
	VB_IN_O		<= VB_IN_I;
	HS_IN_O		<= HS_IN_I;
	VS_IN_O		<= VS_IN_I;
	ID_IN_O		<= ID_IN_I;
	
	-- Route the registers through
	slv_reg0out <= slv_reg0;
	slv_reg1out <= slv_reg1;
	slv_reg2out <= slv_reg2;
	slv_reg3out <= slv_reg3;
	slv_reg4out <= slv_reg4;
	slv_reg5out <= slv_reg5;
	slv_reg6out <= slv_reg6;
	slv_reg7out <= slv_reg7;

end Behavioral;
--End RGB Control architecture