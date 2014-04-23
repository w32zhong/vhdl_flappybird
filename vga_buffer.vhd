-- Display buffer for VGA screen for 2 object game

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_buffer is
   generic (OBJECT_SIZE : natural := 10);
   port(
        video_on: in std_logic;
        pixel_x, pixel_y : in std_logic_vector(0 to OBJECT_SIZE-1);
		  wall_x0, hole_y0 : in std_logic_vector(0 to OBJECT_SIZE-1);
		  wall_x1, hole_y1 : in std_logic_vector(0 to OBJECT_SIZE-1);
		  wall_x2, hole_y2 : in std_logic_vector(0 to OBJECT_SIZE-1);
		  wall_x3, hole_y3 : in std_logic_vector(0 to OBJECT_SIZE-1);
		  bird_x, bird_y : in std_logic_vector(0 to OBJECT_SIZE-1);
        graph_rgb: out std_logic_vector(7 downto 0)
   );
end vga_buffer;

architecture arch of vga_buffer is
   constant WALL_WIDTH: integer:=45;
   constant HOLE_SIZE: integer:=150;
   constant BIRD_SIZE: integer:=32;
	
	signal wall_l0, hole_t0 : unsigned (0 to OBJECT_SIZE-1);
	signal wall_l1, hole_t1 : unsigned (0 to OBJECT_SIZE-1);
	signal wall_l2, hole_t2 : unsigned (0 to OBJECT_SIZE-1);
	signal wall_l3, hole_t3 : unsigned (0 to OBJECT_SIZE-1);
	
   type bird_rom_t is array (0 to BIRD_SIZE - 1)
        of std_logic_vector(0 to BIRD_SIZE - 1);
   -- ROM definition
   constant bird_rom: bird_rom_t :=
   (
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100",  
		"00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100",  
		"00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100",  
		"00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100", 
      "00111100001111000011110000111100");
	
   signal rom_addr, rom_col: unsigned(0 to 4);
   signal rom_data: std_logic_vector(0 to BIRD_SIZE-1);
   signal rom_bit: std_logic;
   ----------------------------------------------

   signal bird_l : unsigned (0 to OBJECT_SIZE-1);
   signal bird_t : unsigned (0 to OBJECT_SIZE-1);
   signal bird_r : unsigned (0 to OBJECT_SIZE-1);
   signal bird_b : unsigned (0 to OBJECT_SIZE-1);

   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(0 to OBJECT_SIZE-1);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;

   ----------------------------------------------
   -- object output signals
   ----------------------------------------------
   signal bird_on, sq_bird_on: std_logic;
	signal wall_on_0, wall_on_1, wall_on_2, wall_on_3: std_logic;
   signal wall_rgb, bird_rgb: std_logic_vector(7 downto 0);

begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   
	---------------------------------------------
	wall_rgb <= "00001100"; -- green
	---------------------------------------------
	wall_l0 <= unsigned(wall_x0);
	hole_t0 <= unsigned(hole_y0);
   -- pixel within wall
   wall_on_0 <=
      '1' when (wall_l0 <= pix_x) and (pix_x <= wall_l0 + WALL_WIDTH) 
		and ((hole_t0 >= pix_y) or (hole_t0 + HOLE_SIZE <= pix_y)) else
      '0';
	
	wall_l1 <= unsigned(wall_x1);
	hole_t1 <= unsigned(hole_y1);
   -- pixel within wall
   wall_on_1 <=
      '1' when (wall_l1 <= pix_x) and (pix_x <= wall_l1 + WALL_WIDTH) 
		and ((hole_t1 >= pix_y) or (hole_t1 + HOLE_SIZE <= pix_y)) else
      '0';
	
	wall_l2 <= unsigned(wall_x2);
	hole_t2 <= unsigned(hole_y2);
   -- pixel within wall
   wall_on_2 <=
      '1' when (wall_l2 <= pix_x) and (pix_x <= wall_l2 + WALL_WIDTH) 
		and ((hole_t2 >= pix_y) or (hole_t2 + HOLE_SIZE <= pix_y)) else
      '0';
		
	wall_l3 <= unsigned(wall_x3);
	hole_t3 <= unsigned(hole_y3);
   -- pixel within wall
   wall_on_3 <=
      '1' when (wall_l3 <= pix_x) and (pix_x <= wall_l3 + WALL_WIDTH) 
		and ((hole_t3 >= pix_y) or (hole_t3 + HOLE_SIZE <= pix_y)) else
      '0';
	---------------------------------------------
	bird_l <= unsigned(bird_x);
   bird_t <= unsigned(bird_y);
   bird_r <= bird_l + BIRD_SIZE - 1;
   bird_b <= bird_t + BIRD_SIZE - 1;
   
   sq_bird_on <=
      '1' when (bird_l<=pix_x) and (pix_x<=bird_r) and
               (bird_t<=pix_y) and (pix_y<=bird_b) else
      '0';
		
   rom_addr <= pix_y(5 to 9) - bird_t(5 to 9);
   rom_col <= pix_x(5 to 9) - bird_l(5 to 9);
   rom_data <= BIRD_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(rom_col));
	
	bird_on <=
      '1' when (sq_bird_on='1') and (rom_bit='1') else
      '0';
		
   bird_rgb <= "10001100";   -- feather color
	
   -- rgb multiplexing circuit
   process(video_on, wall_rgb, bird_rgb, bird_on, 
	wall_on_0, wall_on_1, wall_on_2, wall_on_3) ---------------------------------------------
   begin
      if video_on='0' then
          graph_rgb <= "00000000"; --blank
      else
			
         if bird_on = '1' then
            graph_rgb <= bird_rgb;
         elsif wall_on_0 = '1' then
            graph_rgb <= wall_rgb;
         elsif wall_on_1 = '1' then
            graph_rgb <= wall_rgb;
			elsif wall_on_2 = '1' then
            graph_rgb <= wall_rgb;
         elsif wall_on_3 = '1' then
            graph_rgb <= wall_rgb;
         else
            graph_rgb <= "10111111"; -- blue background
         end if;
      end if;
   end process;
end arch;