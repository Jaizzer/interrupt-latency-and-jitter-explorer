
/* --- 1. Memory Definitions --- */
/* Defines the physical boundaries of the STM3F411 chip */
MEMORY 
{
    FLASH (rx): ORIGIN = 0x08000000, LENGTH = 512K
    RAM (rwx): ORIGIN = 0x20000000, LENGTH = 128K
}

/* Define the end of RAM to use as the Initial Stack pointer since the stack grows downward */
__estack = ORIGIN(RAM) + LENGTH(RAM);


/*  ---2. Sections Mapping ---- */
SECTIONS
{   
    /* The Vector Table: Must be at the very start of Flash (0x08000000) */
    .isr_vector:
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } > FLASH   

    .text : {
        /* Set the initial address to 0 */
        . = 0;
        LONG(__reset_stack_pointer);
        LONG(main | 1);
        /* The whole interrupt table is 332 bytes long. Advance to that position. */
        . = 332;
        /* And here comes the rest of the code */
        *(.text*)
    } > FLASH /* Put this in the flash memory region */
}