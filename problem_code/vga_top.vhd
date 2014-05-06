-- Created by Dr. K
-- Modified by F.Cayci
-- Top level for game with two objects.
-- Convention: (x,y) object coordinates track lower-left corner of the object

library ieee;
use ieee.std_logic_1164.all;
entity vga_top is
    generic (OBJECT_SIZE : natural := 10);
    port (
      clk, reset: in std_logic;
      wall_x0, hole_y0 : in std_logic_vector(0 to OBJECT_SIZE-1);
		wall_x1, hole_y1 : in std_logic_vector(0 to OBJECT_SIZE-1);
		wall_x2, hole_y2 : in std_logic_vector(0 to OBJECT_SIZE-1);
		wall_x3, hole_y3 : in std_logic_vector(0 to OBJECT_SIZE-1);
		bird_x, bird_y : in std_logic_vector(0 to OBJECT_SIZE-1);
		bird1_x, bird1_y : in std_logic_vector(0 to OBJECT_SIZE-1);
		bird2_x, bird2_y : in std_logic_vector(0 to OBJECT_SIZE-1);
      hsync, vsync: out  std_logic;
      rgb: out std_logic_vector(7 downto 0)
   );
end vga_top;

architecture arch of vga_top is
   signal pixel_x, pixel_y: std_logic_vector (0 to OBJECT_SIZE-1);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(7 downto 0);
   signal vsync_reg, vsync_next: std_logic;
   signal hsync_reg, hsync_next: std_logic;
   
begin
  -- instantiate VGA sync
  vga_sync_unit: entity work.vga_sync
    port map(
      clk=>clk, reset=>reset,
      video_on=>video_on,
      hsync=>hsync_next, vsync=>vsync_next,
      pixel_x=>pixel_x, pixel_y=>pixel_y);
  -- instantiate graphic generator
  vga_buffer_unit: entity work.vga_buffer
    generic map (OBJECT_SIZE=>OBJECT_SIZE)
    port map (video_on=>video_on, graph_rgb=>rgb_next,
      pixel_x=>pixel_x, pixel_y=>pixel_y,
		wall_x0 => wall_x0, hole_y0 => hole_y0,
		wall_x1 => wall_x1, hole_y1 => hole_y1,
		wall_x2 => wall_x2, hole_y2 => hole_y2,
		wall_x3 => wall_x3, hole_y3 => hole_y3,
		bird_x => bird_x, bird_y => bird_y,
		bird1_x => bird1_x, bird1_y => bird1_y,
		bird2_x => bird2_x, bird2_y => bird2_y
      );
  -- rgb buffer
  process (clk)
  begin
    if (clk'event and clk='1') then
      rgb_reg <= rgb_next;
      hsync_reg <= hsync_next;
      vsync_reg <= vsync_next;
    end if;
  end process;
  rgb <= rgb_reg;
  hsync <= hsync_reg;
  vsync <= vsync_reg;
end arch;
