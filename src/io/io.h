#ifndef __IO_H
#define __IO_H

//b for 1 bytes
//w for 2 bytes

//my change
extern unsigned char insb(unsigned short port);
extern unsigned short insw(unsigned short port);

//my change
extern void outb(unsigned short port, unsigned char val);
extern void outw(unsigned short port, unsigned short val);


#endif