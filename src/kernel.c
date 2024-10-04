#include "kernel.h"
#include "idt/idt.h"
#include "io/io.h"

uint16_t *video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char c, enum color color)
{
    uint16_t video_memory_double_word = 0;
    switch (color)
    {
    case BLACK:
        video_memory_double_word = (BLACK << 8) | c;

        break;
    case WHITE:
        video_memory_double_word = (WHITE << 8) | c;

        break;
    case RED:
        video_memory_double_word = (RED << 8) | c;

        break;
    case GREEN:
        video_memory_double_word = (GREEN << 8) | c;

        break;
    case BLUE:
        video_memory_double_word = (BLUE << 8) | c;

        break;
    }

    return video_memory_double_word;
}

void terminal_putchar(int x, int y, char c, enum color color)
{
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, color);
}

void terminal_writechar_vertical(char c, enum color color)
{
    if (c == '\n')
    {
        terminal_row = 0;
        terminal_col += 1;
        return;
    }
    terminal_putchar(terminal_col, terminal_row, c, color);
    terminal_row += 1;
    if (terminal_row >= VGA_HEIGHT)
    {
        terminal_col += 1;
        terminal_row = 0;
    }
}

void terminal_writechar_horizental(char c, enum color color)
{
    if (c == '\n')
    {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }
    terminal_putchar(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if (terminal_col >= VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void terminal_initialize()
{
    // start at address 0xB8000 for display
    video_mem = (uint16_t *)0xB8000;
    terminal_row = 0;
    terminal_col = 0;

    for (size_t y = 0; y < VGA_HEIGHT; y++)
    {
        for (size_t x = 0; x < VGA_WIDTH; x++)
        {
            terminal_putchar(x, y, ' ', BLACK);
        }
    }
}

size_t strlen(const char *string)
{
    size_t len = 0;
    while (string[len])
    {
        len++;
    }

    return len;
}

void print(const char *str, enum color color)
{
    size_t len = strlen(str);
    for (int i = 0; i < len; i++)
    {
        terminal_writechar_horizental(str[i], color);
    }
}

void kernel_main()
{
    // empty whole console by making it black
    terminal_initialize();
    print("Welcome to fire temple os!", WHITE);

    //initilize the interrupt descriptor table
    idt_init();

    outb(0x60,0xff);
}