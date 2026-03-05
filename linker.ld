
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

        /* 4. glue_7 and glue_7t: THE BITE-SIZE GEARBOX 
         * This is where the "Plus 1" is used to toggle the CPU's internal 
         * Mode Switch, determining if it swallows 16 or 32 bits.
         */

        /* * 4a. .glue_7: ARM to Thumb (The 16-bit Swallow)
         * EXAMPLE: The 32-bit ARM math function returns to your 16-bit main.c.
         * 1. THE START: main.c physically begins at ORIGINAL ADDRESS 0x08000100.
         * 2. THE TOGGLE: To return to Thumb, the Linker conducts address 0x08000101 (+1).
         * 3. MODE SWITCH: Hardware sees Bit 0 is '1' and toggles to THUMB mode.
         * 4. SWALLOW AMOUNT: The CPU reconfigures (glue is the toggler) to grab 16-bit (2-byte) chunks starting at ORIGINAL ADDRESS 0x08000100.
         */
        *(.glue_7)

        /* * 4b. .glue_7t: Thumb to ARM (The 32-bit Swallow)
         * EXAMPLE: Your 16-bit main.c calls the 32-bit ARM math function.
         * 1. THE START: Math function physically begins at ORIGINAL ADDRESS 0x08000500.
         * 2. THE TOGGLE: To enter ARM, the Linker conducts address 0x08000500 (Ends in 0).
         * 3. MODE SWITCH: Hardware sees Bit 0 is '0' and toggles to ARM mode.
         * 4. SWALLOW AMOUNT: The CPU reconfigures (glue is the toggler)  to grab 32-bit (4-byte) chunks starting at ORIGINAL ADDRESS 0x08000500.
         */
        *(.glue_7t)


    } > FLASH
}