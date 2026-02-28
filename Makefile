# Project Configuration
TARGET = application
MCU = -mcpu=cortex-m4-mthumb

# Toolchain
CC = arm-none-eabi-gcc
OBJCOPY = arm-non-eabi-gcc-objcopy

# Search paths
CMSIS_CORE = ./CMSIS_5/CMSIS/Core/Include
CMSIS_DEV = ./cmsis_device_f4/Include

blinky:
	arm-none-eabi-gcc -c -g -mcpu=cortex-m4 -mthumb -ffreestanding main.o main.c
	arm-none-eabi-gcc -o application.elf -T linker.ld -nostdlib -nostartfiles main.o
	arm-none-eabi-objcopy -O binary application.elf application.bin
	st-flash write application.bin 0x08000000
	st-flash reset    