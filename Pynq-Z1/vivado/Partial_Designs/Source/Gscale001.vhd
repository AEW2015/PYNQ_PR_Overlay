----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2017 10:24:00 AM
-- Design Name: 
-- Module Name: Video_pr_block - Behavioral
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
    
    -- Bus Clock
    CLK : in std_logic;
	
	-- Video input Signals
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

--Begin Grayscale architecture design
architecture Behavioral of Video_Box is

	--Define a Divide function for use in the grayscale
	function  divide  (a : UNSIGNED; b : UNSIGNED) return UNSIGNED is
	--Variables used in the divide algorithm
	variable a1 : unsigned(a'length-1 downto 0):=a;
	variable b1 : unsigned(b'length-1 downto 0):=b;
	variable p1 : unsigned(b'length downto 0):= (others => '0');
	variable i : integer:=0;

	--Begin Divide Algorithm
	begin
		for i in 0 to b'length-1 loop
			p1(b'length-1 downto 1) := p1(b'length-2 downto 0);
			p1(0) := a1(a'length-1);
			a1(a'length-1 downto 1) := a1(a'length-2 downto 0);
			p1 := p1-b1;
			if(p1(b'length-1) ='1') then
				a1(0) :='0';
				p1 := p1+b1;
			else
				a1(0) :='1';
			end if;
		end loop;
	return a1;

	end divide; 
	--End Divide

	--Grayscale signal (contains the average value of all three pixels)
	signal grayscale : std_logic_vector(7 downto 0);
	--Const of a three
	signal three_const : unsigned(7 downto 0):= "00000011";
	--Sum signal
	signal sum : unsigned(9 downto 0);	

begin

	--Add the value of Red, Green, and Blue together
	sum <= unsigned("00" & RGB_IN_I(23 downto 16)) + unsigned("00" & RGB_IN_I(15 downto 8)) + unsigned("00" & RGB_IN_I(7 downto 0));
	--Divide by 3 to get the average RGB value for the pixel
	grayscale <= std_logic_vector(divide ( sum, three_const )(6 downto 0))&'0';

	--Concatenate the grayscale average together and place on the RGB output
	RGB_IN_O 	<= grayscale & grayscale & grayscale;

	--Pass all the other signals through the region
	VDE_IN_O	<= VDE_IN_I;
	HB_IN_O		<= HB_IN_I;
	VB_IN_O		<= VB_IN_I;
	HS_IN_O		<= HS_IN_I;
	VS_IN_O		<= VS_IN_I;
	ID_IN_O		<= ID_IN_I;

	--Pass the registers through the region
	slv_reg0out <= slv_reg0;
	slv_reg1out <= slv_reg1;
	slv_reg2out <= slv_reg2;
	slv_reg3out <= slv_reg3;
	slv_reg4out <= slv_reg4;
	slv_reg5out <= slv_reg5;
	slv_reg6out <= slv_reg6;
	slv_reg7out <= slv_reg7;

end Behavioral;
--End Grayscale