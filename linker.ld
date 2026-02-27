MEMORY 
{
    FLASH (rx): ORIGIN = 0x08000000, LENGTH = 512K
    RAM (rwx): ORIGIN = 0x20000000, LENGTH = 128K
}
__estack = ORIGIN(RAM) + LENGTH(RAM);


SECTIONS
{
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