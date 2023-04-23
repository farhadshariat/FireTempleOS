#ifndef __KERNEL_H
#define __KERNEL_H

#include <stdint.h>
#include <stddef.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 20
#define VGA_BYTE_ALLOCATED VGA_WIDTH * VGA_HEIGHT * 2

enum color
{
    BLACK = 0,
    BLUE = 1,
    GREEN = 3,
    RED = 4,
    WHITE = 15,
};

void print(const char *str, enum color color);

void kernel_main();

#endif