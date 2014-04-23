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

int main() 
{
	volatile int Delay;
	float y = 100.f;
	unsigned int wall_x[4];
	unsigned int hole_y[4];
	unsigned int bird_x;
	unsigned int bird_y;
	wall_x[0] = 100; hole_y[0] = 50;
	wall_x[1] = 200; hole_y[1] = 150;
	wall_x[2] = 300; hole_y[2] = 200;
	wall_x[3] = 400; hole_y[3] = 250;
	bird_x = 40;

	u32 DataRead;
	char lock = 1;

	   while (1) {
		   bird_y = (unsigned int)y;

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

		   if (DataRead == 2) {
			   lock = 0;
			   y -= 1.5;
		   }

		   if (lock == 0) {
			   y += 0.5f;
		   }

		   DELAY;
	   }

	   return 0;
}

