#include "idt.h"
#include "kernel.h"
#include "config.h"
#include "memory.h"
#include "io/io.h"

static struct idt_desc idt_descriptors[FIRETEMPLEOS_TOTAL_INTERRUPTS];

static struct idtr_desc idtr_descriptor;

extern void idt_load(struct idtr_desc* ptr);
extern void int21h();
extern void no_interrupt();

void int21h_handler()
{
    print("Keyboard pressed!\n", WHITE);
    // tell PIC we are done handling interrupt
    outb(0x20, 0x20);
}

void no_interrupt_handler()
{
    // tell PIC we are done handling interrupt
    outb(0x20, 0x20);
}

void idt_zero()
{
    print("Devide by zero error\n", WHITE);
}

static void idt_set(int interrupt_num, void* address)
{
    struct idt_desc* desc = &idt_descriptors[interrupt_num];
    desc->offset_1 = (uint32_t)address & 0x0000ffff;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0x00;
    desc->type_attr = 0xEE;
    desc->offset_2 = (uint32_t)address >> 16;
}

void idt_init()
{
    memset(idt_descriptors , 0 , sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t)idt_descriptors;

    for (size_t i = 0; i < FIRETEMPLEOS_TOTAL_INTERRUPTS; i++)
    {
        idt_set(i, no_interrupt);
    }
    
    idt_set(0, idt_zero);
    idt_set(0x21, int21h);

    //load the interrupt descriptor table
    idt_load(&idtr_descriptor);
}
