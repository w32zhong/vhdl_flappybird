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
		  bird1_x, bird1_y : in std_logic_vector(0 to OBJECT_SIZE-1);
		  bird2_x, bird2_y : in std_logic_vector(0 to OBJECT_SIZE-1);
        graph_rgb: out std_logic_vector(7 downto 0)
   );
end vga_buffer;

architecture arch of vga_buffer is
   constant WALL_WIDTH: integer:=45;
   constant HOLE_SIZE: integer:=150;
   
	signal wall_l0, hole_t0 : unsigned (0 to OBJECT_SIZE-1);
	signal wall_l1, hole_t1 : unsigned (0 to OBJECT_SIZE-1);
	signal wall_l2, hole_t2 : unsigned (0 to OBJECT_SIZE-1);
	signal wall_l3, hole_t3 : unsigned (0 to OBJECT_SIZE-1);
	
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(0 to OBJECT_SIZE-1);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;

   ----------------------------------------------
   -- object output signals
   ----------------------------------------------
   signal wall_on_0, wall_on_1, wall_on_2, wall_on_3: std_logic;
   signal wall_rgb, bird_rgb: std_logic_vector(7 downto 0);
	
	------test
	constant TEST_SIZE_W: integer:= 46;
	constant TEST_BITS_W: integer:= 6;
	constant TEST_SIZE_H: integer:= 33;
	constant TEST_BITS_H: integer:= 6;
	type color_rom_t is array (0 to TEST_SIZE_H - 1, 0 to TEST_SIZE_W - 1)
        of integer range 0 to 255;
   -- ROM definition
   constant test_rom: color_rom_t :=
(
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 219 , 219 , 219 , 219 , 219 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 255 , 255 , 255 , 254 , 254 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 219 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 219 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 219 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 219 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 72 , 0 , 0 , 219 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 219 , 219 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 221 , 221 , 221 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 221 , 221 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 184 , 184 , 184 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 252 , 220 , 220 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 220 , 220 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 ),
  ( 118 , 0 , 0 , 220 , 220 , 220 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 255 , 220 , 220 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 150 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 32 , 0 , 0 , 118 ),
  ( 118 , 118 , 118 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 32 , 0 , 0 , 118 ),
  ( 118 , 118 , 118 , 0 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 220 , 0 , 0 , 0 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 32 , 0 , 0 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 248 , 248 , 244 , 248 , 248 , 248 , 248 , 68 , 0 , 0 , 232 , 232 , 232 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 122 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 68 , 0 , 0 , 232 , 232 , 232 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 217 , 216 , 216 , 216 , 216 , 216 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 216 , 216 , 216 , 32 , 32 , 32 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 204 , 0 , 0 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 216 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 0 , 0 , 0 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 0 , 0 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 216 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 0 , 0 , 0 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 232 , 0 , 0 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 216 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 248 , 244 , 248 , 248 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 4 , 4 , 4 , 4 , 4 , 4 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 213 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 4 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 ),
  ( 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 , 118 )
);
	
	signal test_rom_x: unsigned(0 to TEST_BITS_W - 1);
	signal test_rom_y: unsigned(0 to TEST_BITS_H - 1);
   signal test_rom_val: std_logic_vector(0 to 7);
	signal test_on, sq_test_on: std_logic;
	signal test_l : unsigned (0 to OBJECT_SIZE-1);
   signal test_t : unsigned (0 to OBJECT_SIZE-1);
   signal test_r : unsigned (0 to OBJECT_SIZE-1);
   signal test_b : unsigned (0 to OBJECT_SIZE-1);

	------bird1
	constant bird1_SIZE_W: integer:= 4;
	constant bird1_BITS_W: integer:= 2;
	constant bird1_SIZE_H: integer:= 4;
	constant bird1_BITS_H: integer:= 2;
	type bird1_color_rom_t is array (0 to bird1_SIZE_H - 1, 0 to bird1_SIZE_W - 1)
        of integer range 0 to 255;
   -- ROM definition
   constant bird1_rom: bird1_color_rom_t :=
(
	(1, 2, 3, 4),
	(1, 2, 3, 4),
	(1, 2, 3, 4),
	(1, 2, 3, 4)
);

	signal bird1_rom_x: unsigned(0 to bird1_BITS_W - 1);
	signal bird1_rom_y: unsigned(0 to bird1_BITS_H - 1);
   signal bird1_rom_val: std_logic_vector(0 to 7);
	signal bird1_on, sq_bird1_on: std_logic;
	signal bird1_l : unsigned (0 to OBJECT_SIZE-1);
   signal bird1_t : unsigned (0 to OBJECT_SIZE-1);
   signal bird1_r : unsigned (0 to OBJECT_SIZE-1);
   signal bird1_b : unsigned (0 to OBJECT_SIZE-1);
	
	------bird2
	constant bird2_SIZE_W: integer:= 4;
	constant bird2_BITS_W: integer:= 2;
	constant bird2_SIZE_H: integer:= 4;
	constant bird2_BITS_H: integer:= 2;
	type bird2_color_rom_t is array (0 to bird2_SIZE_H - 1, 0 to bird2_SIZE_W - 1)
        of integer range 0 to 255;
   -- ROM definition
   constant bird2_rom: bird2_color_rom_t :=
(
	(1, 2, 3, 4),
	(1, 2, 3, 4),
	(1, 2, 3, 4),
	(1, 2, 3, 4)
);

	signal bird2_rom_x: unsigned(0 to bird2_BITS_W - 1);
	signal bird2_rom_y: unsigned(0 to bird2_BITS_H - 1);
   signal bird2_rom_val: std_logic_vector(0 to 7);
	signal bird2_on, sq_bird2_on: std_logic;
	signal bird2_l : unsigned (0 to OBJECT_SIZE-1);
   signal bird2_t : unsigned (0 to OBJECT_SIZE-1);
   signal bird2_r : unsigned (0 to OBJECT_SIZE-1);
   signal bird2_b : unsigned (0 to OBJECT_SIZE-1);
begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
	
	-----------test----------------------------------
	test_l <= unsigned(bird_x);
   test_t <= unsigned(bird_y);
   test_r <= test_l + TEST_SIZE_W - 1;
   test_b <= test_t + TEST_SIZE_H - 1;
    
   sq_test_on <=
      '1' when (test_l<=pix_x) and (pix_x<=test_r) and
               (test_t<=pix_y) and (pix_y<=test_b) else
      '0';
		
   test_rom_y <= pix_y(9 - TEST_BITS_H + 1 to 9) - test_t(9 - TEST_BITS_H + 1 to 9);
   test_rom_x <= pix_x(9 - TEST_BITS_W + 1 to 9) - test_l(9 - TEST_BITS_W + 1 to 9);
   test_rom_val <= std_logic_vector(to_unsigned(
		test_rom(to_integer(test_rom_y),to_integer(test_rom_x)),
		8));
	test_on <= '1' when  sq_test_on = '1' and 
		test_rom_val /= std_logic_vector(to_unsigned(118, 8)) 
		else '0';
		
	-----------bird1----------------------------------
	bird1_l <= unsigned(bird1_x);
   bird1_t <= unsigned(bird1_y);
   bird1_r <= bird1_l + bird1_SIZE_W - 1;
   bird1_b <= bird1_t + bird1_SIZE_H - 1;
    
   sq_bird1_on <=
      '1' when (bird1_l<=pix_x) and (pix_x<=bird1_r) and
               (bird1_t<=pix_y) and (pix_y<=bird1_b) else
      '0';
		
   bird1_rom_y <= pix_y(9 - bird1_BITS_H + 1 to 9) - bird1_t(9 - bird1_BITS_H + 1 to 9);
   bird1_rom_x <= pix_x(9 - bird1_BITS_W + 1 to 9) - bird1_l(9 - bird1_BITS_W + 1 to 9);
   bird1_rom_val <= std_logic_vector(to_unsigned(
		bird1_rom(to_integer(bird1_rom_y),to_integer(bird1_rom_x)),
		8));
	bird1_on <= '1' when  sq_bird1_on = '1' and 
		bird1_rom_val /= std_logic_vector(to_unsigned(118, 8)) 
		else '0';
   
	-----------bird2----------------------------------
	bird2_l <= unsigned(bird2_x);
   bird2_t <= unsigned(bird2_y);
   bird2_r <= bird2_l + bird2_SIZE_W - 1;
   bird2_b <= bird2_t + bird2_SIZE_H - 1;
    
   sq_bird2_on <=
      '1' when (bird2_l<=pix_x) and (pix_x<=bird2_r) and
               (bird2_t<=pix_y) and (pix_y<=bird2_b) else
      '0';
		
   bird2_rom_y <= pix_y(9 - bird2_BITS_H + 1 to 9) - bird2_t(9 - bird2_BITS_H + 1 to 9);
   bird2_rom_x <= pix_x(9 - bird2_BITS_W + 1 to 9) - bird2_l(9 - bird2_BITS_W + 1 to 9);
   bird2_rom_val <= std_logic_vector(to_unsigned(
		bird2_rom(to_integer(bird2_rom_y),to_integer(bird2_rom_x)),
		8));
	bird2_on <= '1' when  sq_bird2_on = '1' and 
		bird2_rom_val /= std_logic_vector(to_unsigned(118, 8)) 
		else '0';
		
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
	
   -- rgb multiplexing circuit
   process(video_on, wall_rgb,
	wall_on_0, wall_on_1, wall_on_2, wall_on_3, ---------------------------------------------
	test_on, test_rom_val,
	bird1_on, bird1_rom_val,
	bird2_on, bird2_rom_val
	) ---------------------------------------------
   begin
      if video_on='0' then
          graph_rgb <= "00000000"; --blank
      else
			
         if test_on = '1' then
            graph_rgb <= test_rom_val;
         elsif bird1_on = '1' then
            graph_rgb <= bird1_rom_val;
			elsif bird2_on = '1' then
            graph_rgb <= bird2_rom_val;
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
