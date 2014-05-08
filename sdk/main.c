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

volatile Xuint16 *ssegment = (Xuint16 *) XPAR_SVN_SEG_AXI_0_BASEADDR;

#define WALL_WIDTH (45)
#define HOLE_SIZE (150)
#define BIRD_SIZE (32)

unsigned int rand_hole()
{
	return 50 + rand() % 200;
}

void update_wall(float *wall, unsigned int *hole, float bird_x)
{
	float new_pos;

	if (*wall <= 0.f) {
		*hole = rand_hole();
		*wall = 610.f;
	} else {
		new_pos = *wall - 0.25f;
		if (*wall + WALL_WIDTH > bird_x &&
				new_pos + WALL_WIDTH <= bird_x)
			ssegment[0] ++;
		*wall = new_pos;
	}
}

int test_hit(unsigned int bird_x, unsigned int bird_y,
		unsigned int wall_x, unsigned int hole_y)
{
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
		lock = 1; \
		j = 0; \
		ssegment[0] = (Xuint16)0x0000;

int main() 
{
	volatile int Delay, move_delay;
	int i, j;
	float y, a, wall0, wall1, wall2, wall3;
	unsigned int bird_x, bird_y, wall_x[4] , hole_y[4], game_over, lock;

	unsigned int bird_ani_x[3], bird_ani_y[3];
	u32 DataRead;
	// x, y = [640, 480];

	INIT_GAME;
	begin:
	   while (1) {
		   bird_y = (unsigned int)y;

		   for (i = 0; i < 3; i++) {
			   if (i == j) {
				   bird_ani_x[i] = bird_x;
				   bird_ani_y[i] = bird_y;

			   } else {
				   bird_ani_x[i] = 700;
				   bird_ani_y[i] = 700;
			   }
		   }

		   move_delay ++;
		   if (move_delay > 50) {
		   	j = (j + 1) % 3;
		   	move_delay = 0;
		   }

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

		   putfsl(bird_ani_x[0], 0);
		   putfsl(bird_ani_y[0], 0);
		   putfsl(bird_ani_x[1], 0);
		   putfsl(bird_ani_y[1], 0);

		   putfsl(wall_x[3], 0);
		   putfsl(hole_y[3], 0);
		   putfsl(wall_x[2], 0);
		   putfsl(hole_y[2], 0);
		   putfsl(wall_x[1], 0);
		   putfsl(hole_y[1], 0);
		   putfsl(wall_x[0], 0);
		   putfsl(hole_y[0], 0);
		   putfsl(bird_ani_x[2], 0);
		   putfsl(bird_ani_y[2], 0);

		   GpioInputExample(XPAR_PUSH_BUTTONS_4BITS_DEVICE_ID, &DataRead);

		   if (DataRead == 2 && !game_over) {
			   lock = 0;
			   y -= 0.5f;
			   a = - 0.5f;
		   }

		   if (lock == 0) {
			   y += a;
			   a += 0.018f;

			   if (y >= 480.f - 15.f) {
				   y = 480.f - 15.f;
				   break;
			   }

			   if (!game_over) {
				   update_wall(&wall0, hole_y + 0, (float)bird_x);
				   update_wall(&wall1, hole_y + 1, (float)bird_x);
				   update_wall(&wall2, hole_y + 2, (float)bird_x);
				   update_wall(&wall3, hole_y + 3, (float)bird_x);
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

