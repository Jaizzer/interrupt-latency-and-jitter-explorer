
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
         * The "Snap to Grid" rule. ARM CPUs are 32-bit and grab data in 4-byte 
         * chunks. If the current address is 0x08000002, this command adds 
         * 2 bytes of padding to push it to 0x08000004. If it's at 0x08000003, 
         * it adds 1 byte. This ensures the table starts on a clean 'lane'.
         */
        . = ALIGN(4);

        /* * 2. KEEP(*(.isr_vector))
         * THE PROTECTOR: Tells the Linker NOT to delete this section. 
         * Since the hardware uses this table (not the software), the 
         * linker's garbage collector would otherwise throw it away.
         */
        KEEP(*(.isr_vector))

        /* * 3. . = ALIGN(4);
         * The "Exit Alignment". Ensures that whatever follows this table 
         * (your code) also starts on a multiple of 4. This prevents 
         * 'misaligned access' which can slow down the CPU or cause crashes 
         * when jumping to your functions.
         */
        . = ALIGN(4);
    } > FLASH   /* This "> FLASH" tells the linker to put this block at 0x08000000 */
    
    .text {
         /* * 1. . = ALIGN(4);
         * The "Snap to Grid" rule. ARM CPUs are 32-bit and grab data in 4-byte 
         * chunks. If the current address is 0x08000002, this command adds 
         * 2 bytes of padding to push it to 0x08000004. If it's at 0x08000003, 
         * it adds 1 byte. This ensures the table starts on a clean 'lane'.
         */
        . = ALIGN(4);

        /* 2. *(.text): The "Standard Bucket"
         * Grabs the default code blocks from every object file. This is 
         * where code goes if it was compiled WITHOUT '-ffunction-sections', 
         * which is common for pre-compiled Standard Libraries (libc.a).
         */
        *(.text)

        /* 3. *(.text*): The "Wildcard Bucket"
         * Grabs sub-sections like .text.main or .text.Reset_Handler.
         * - In C: Needed if you use '-ffunction-sections' (every function gets a bucket).
         * - In Assembly: Needed because handlers are explicitly named (e.g., .text.Reset_Handler).
         * Without this wildcard, your Startup code would be ignored by the linker.
         */
        *(.text*)
        


    } > FLASH
}