/*
 * Copyright (c) 2018 PHYTEC Messtechnik GmbH
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr.h>
#include <device.h>
#include <display/cfb.h>
#include <stdio.h>
#include <time.h>

#if defined(CONFIG_SSD16XX)
#define DISPLAY_DRIVER		"SSD16XX"
#endif

#if defined(CONFIG_SSD1306)
#define DISPLAY_DRIVER		"SSD1306"
#endif

#ifndef DISPLAY_DRIVER
#define DISPLAY_DRIVER		"DISPLAY"
#endif

uint16_t center_coord(uint16_t full_size, uint16_t item_size) {
	uint16_t center = full_size / 2 - item_size / 2;
	return center - center % 8;
}

int time_str_hms(char buffer[9]) {
	time_t t = time(NULL);
	struct tm * lt = localtime(&t);

	return snprintf(buffer, 9, "%02d:%02d:%02d", lt->tm_hour, lt->tm_min, lt->tm_sec);
}

int draw_time_center(const struct device *dev, uint16_t display_width, uint16_t display_height, uint8_t font_width, uint8_t font_height) {
	char buffer[9];
	int text_len = time_str_hms(buffer);

	uint16_t x = center_coord(display_width, text_len * font_width);
	uint16_t y = center_coord(display_height, font_height);

	return cfb_print(dev, buffer, x, y);
}

void main(void)
{
	const struct device *dev;
	uint8_t font_width;
	uint8_t font_height;

	dev = device_get_binding(DISPLAY_DRIVER);

	if (dev == NULL) {
		printf("Device not found\n");
		return;
	}

	if (display_set_pixel_format(dev, PIXEL_FORMAT_MONO10) != 0) {
		printf("Failed to set required pixel format\n");
		return;
	}

	printf("initialized %s\n", DISPLAY_DRIVER);

	if (cfb_framebuffer_init(dev)) {
		printf("Framebuffer initialization failed!\n");
		return;
	}

	cfb_framebuffer_clear(dev, true);

	display_blanking_off(dev);

	for (int idx = 0; idx < 42; idx++) {
		if (cfb_get_font_size(dev, idx, &font_width, &font_height)) {
			break;
		}
		cfb_framebuffer_set_font(dev, idx);
		printf("font width %d, font height %d\n",
		       font_width, font_height);
	}

	uint16_t display_width = cfb_get_display_parameter(dev, CFB_DISPLAY_WIDTH);
	uint16_t display_height = cfb_get_display_parameter(dev, CFB_DISPLAY_HEIGH);

	while (1) {
		cfb_framebuffer_clear(dev, false);

		if (draw_time_center(dev,
					display_width, display_height,
					font_width, font_height)) {
			printf("Failed to print a string\n");
			k_sleep(K_MSEC(10000));
			continue;
		}

		cfb_framebuffer_finalize(dev);

		k_sleep(K_MSEC(1000));
	}
}
