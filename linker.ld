
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
    /* -----------------------------
     * This is the most important block in your firmware. On power-up, the 
     * STM32 hardware is hard-wired to look at address 0x08000000. 
     * It expects to find the "Vector Table" here.
     *
     * IMPORTANT: The actual data (words) for this section are defined in 
     * your ASSEMBLY file (usually startup_stm32f411xe.s). This linker 
     * block just grabs that assembly data and places it at the very front.
     */
    .isr_vector :
    {
        /* * 1. . = ALIGN(4);
         * The ARM CPU is 32-bit. It cannot read the vector table if it starts 
         * on an odd address. This forces the table to start on a 4-byte boundary.
         */
        . = ALIGN(4);

        /* * 2. KEEP(*(.isr_vector))
         * THE PROTECTOR: Because no C function (like main) ever calls the 
         * vector table, the Linker thinks it is "unused code" and will try 
         * to delete it to save space. KEEP tells the linker: "This is for 
         * the hardware, not the software. Do NOT delete it!"
         * * The * means "look in all files" (including your ASSEMBLY file), 
         * and (.isr_vector) is the section label inside that assembly file.
         */
        KEEP(*(.isr_vector))

        /* * 3. . = ALIGN(4);
         * Ensures that whatever comes after the table (your code) also starts 
         * on a clean 32-bit boundary for maximum speed.
         */
        . = ALIGN(4);

    } > FLASH   /* This "> FLASH" tells the linker to put this block at 0x08000000 */
    
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