----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:48:58 04/12/2014 
-- Design Name: 
-- Module Name:    vga_wapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_wapper is
	port (
		GCLK : in std_logic;
		RESET : in std_logic;
		vga_fsl_0_rgb_pin: out std_logic_vector(7 downto 0);
		vga_fsl_0_hsync_pin: out std_logic;
		vga_fsl_0_vsync_pin: out std_logic
	);
end vga_wapper;

architecture Behavioral of vga_wapper is
	component clkgen
	port
	 (-- Clock in ports
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  CLK_OUT1          : out    std_logic;
	  -- Status and control signals
	  RESET             : in     std_logic
	 );
	end component;
	signal clk_25MHz_w: std_logic;
begin
	clk_25MHz_unit: clkgen
	port map
		(-- Clock in ports
		 CLK_IN1 => GCLK,
		 -- Clock out ports
		 CLK_OUT1 => clk_25MHz_w,
		 -- Status and control signals
		 RESET  => RESET);
	 
	vga_unit: entity work.vga_top(arch)
      port map(
			clk => clk_25MHz_w,
			reset => reset,
			hsync=>vga_fsl_0_hsync_pin,
			vsync=>vga_fsl_0_vsync_pin,
			rgb=>vga_fsl_0_rgb_pin,
			wall_x0 => (others=>'0'),
			hole_y0 => "0001100111",
			wall_x1 => "0011110111",
			hole_y1 => "0000011111",
			wall_x2 => "0111000000",
			hole_y2 => "0010011111",
			wall_x3 => "0110000000",
			hole_y3 => "0011001111",
			bird_x => (others=>'0'),
			bird_y => (others=>'0'));
			
end Behavioral;

