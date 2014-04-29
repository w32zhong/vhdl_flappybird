#include <stdio.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "uartlite_header.h"
#include "xbasic_types.h"
#include "xgpio.h"
#include "gpio_header.h"
#include "vga_fsl.h"
#include <stdlib.h>

#define DELAY \
	for (Delay = 0; Delay < 20000; Delay++)

unsigned int rand_hole()
{
	return 50 + rand() % 200;
}

void update_wall(float *wall, unsigned int *hole)
{
	if (*wall <= 0.f) {
		*hole = rand_hole();
		*wall = 610.f;
	} else
		*wall = *wall - 0.25f;
}

int test_hit(unsigned int bird_x, unsigned int bird_y,
		unsigned int wall_x, unsigned int hole_y)
{
#define WALL_WIDTH (45)
#define HOLE_SIZE (150)
#define BIRD_SIZE (32)
	if (!(bird_x >= wall_x + WALL_WIDTH || bird_x + BIRD_SIZE <= wall_x)) {
		if (bird_y + BIRD_SIZE >= hole_y + HOLE_SIZE ||
				bird_y <= hole_y)
		return 1;

	}

	return 0;
}

#define INIT_GAME \
		game_over = 0; \
		y = 250.f, a = 0.f; \
		wall0 = 200.f; wall1 = 350.f; wall2 = 500.f; wall3 = 650.f; \
		wall_x[0] = 300; hole_y[0] = rand_hole(); \
		wall_x[1] = 300; hole_y[1] = rand_hole(); \
		wall_x[2] = 300; hole_y[2] = rand_hole(); \
		wall_x[3] = 300; hole_y[3] = rand_hole(); \
		bird_x = 100; \
		lock = 1;

int main() 
{
	volatile int Delay;
	float y, a, wall0, wall1, wall2, wall3;
	unsigned int bird_x, bird_y, wall_x[4] , hole_y[4], game_over, lock;
	u32 DataRead;
	// x, y = [640, 480];

	INIT_GAME;
	begin:
	   while (1) {
		   bird_y = (unsigned int)y;
		   wall_x[0] = wall0;
		   wall_x[1] = wall1;
		   wall_x[2] = wall2;
		   wall_x[3] = wall3;

		   if (test_hit(bird_x, bird_y, wall_x[0], hole_y[0]))
			   game_over = 1;
		   if (test_hit(bird_x, bird_y, wall_x[1], hole_y[1]))
			   game_over = 1;
		   if (test_hit(bird_x, bird_y, wall_x[2], hole_y[2]))
			   game_over = 1;
		   if (test_hit(bird_x, bird_y, wall_x[3], hole_y[3]))
			   game_over = 1;

		   putfsl(wall_x[3], 0);
		   putfsl(hole_y[3], 0);
		   putfsl(wall_x[2], 0);
		   putfsl(hole_y[2], 0);
		   putfsl(wall_x[1], 0);
		   putfsl(hole_y[1], 0);
		   putfsl(wall_x[0], 0);
		   putfsl(hole_y[0], 0);
		   putfsl(bird_x, 0);
		   putfsl(bird_y, 0);

		   GpioInputExample(XPAR_PUSH_BUTTONS_4BITS_DEVICE_ID, &DataRead);

		   if (DataRead == 2 && !game_over) {
			   lock = 0;
			   a = - 0.6f;
		   }

		   if (lock == 0) {
			   y += a;
			   a += 0.014f;

			   if (y >= 480.f - 15.f) {
				   y = 480.f - 15.f;
				   break;
			   }

			   if (!game_over) {
				   update_wall(&wall0, hole_y + 0);
				   update_wall(&wall1, hole_y + 1);
				   update_wall(&wall2, hole_y + 2);
				   update_wall(&wall3, hole_y + 3);
			   }
		   }

		   DELAY;
	   }

	   while (1) {
		   GpioInputExample(XPAR_PUSH_BUTTONS_4BITS_DEVICE_ID, &DataRead);
		   if (DataRead == 1) {
			   INIT_GAME;
			   goto begin;
		   }

		   DELAY;
	   }

	   return 0;
}

