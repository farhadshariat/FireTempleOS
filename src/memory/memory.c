#include "memory.h"

void* memset(void* ptr, int c, size_t size)
{
    char* c_ptr  = (char*) ptr;
    for (int i = 0; i < size; i++)
    {
        c_ptr[i] = (char)c;
    }
    
    return ptr;
}

void* memcpy(void* dest, void* src, size_t size)
{
    char* d_ptr  = (char*) dest;
    char* s_ptr  = (char*) src;
    for (int i = 0; i < size; i++)
    {
        d_ptr[i] = s_ptr[i];
    }
    
    return dest;
}

