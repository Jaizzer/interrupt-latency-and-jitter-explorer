#include "stm32f411xe.h"
#include <stdint.h>

// This variables will be used to calculate the jitter
volatile uint32_t start_time = 0;
volatile uint32_t end_time = 0;
volatile uint32_t actual_period = 0;
volatile uint32_t target_period = 0;
volatile int32_t jitter = 0;

/**
 * @brief  Main program
 * @note   This code demonstrates a basic interrupt-driven blinky
 * with latency measurement using the DWT cycle counter.
 */
int main(void) {
    /* Reset and Enable DWT Cycle Counter (for latency measurement) */
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;

    /* Power: Enable GPIOA, GPIOB, GPIOC, TIM2, and SYSCONFIG
       - GPIOA, GPIOB, GPIOC are on the High-Speed AHB1 bus
       - TIM2 is on the Peripheral APB1 bus
       - SYSCONFIG is on the Peripheral APB2 bus */
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOBEN;
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOCEN;
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;
    RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;

    /* Wire the PC13 (Blue button) to EXTI13 */
    SYSCFG->EXTICR[3] &= ~SYSCFG_EXTICR4_EXTI13;
    SYSCFG->EXTICR[3] |= SYSCFG_EXTICR4_EXTI13_PC;

    /* Enable the interrupt for EXTI13*/
    EXTI->IMR |= EXTI_IMR_MR13;

    /* Detect the interrupt on button press since the blue button is active low */
    EXTI->FTSR |= EXTI_FTSR_TR13;
    EXTI->RTSR &= ~EXTI_RTSR_TR13;

    /* GPIO Setup: Set PA5 to General Purpose Output (01) */
    GPIOA->MODER &= ~GPIO_MODER_MODE5;
    GPIOA->MODER |= GPIO_MODER_MODE5_0;

    /* GPIO Setup: Set PA0 to General Purpose Output (01) */
    GPIOA->MODER &= ~GPIO_MODER_MODE0;
    GPIOA->MODER |= GPIO_MODER_MODE0_0;

    /* GPIO Setup: Set PB3 to General Purpose Output (01) */
    GPIOB->MODER &= ~GPIO_MODER_MODE3;
    GPIOB->MODER |= GPIO_MODER_MODE3_0;

    /* Timer Setup
       - If the light should blink every 0.5s then
       Xs = ((PSC + 1) * (ARR + 1)) / 16,000,000Hz */
    TIM2->PSC = 5399;
    TIM2->ARR = 1499;

    /* Update start_time for the first time TIMER 2 PSC starts counting */
    start_time = DWT->CYCCNT;

    /* Start the PSC timer */
    TIM2->CR1 |= TIM_CR1_CEN;

    /* Enable Timer interrupt */
    TIM2->DIER |= TIM_DIER_UIE;
    NVIC_SetPriority(TIM2_IRQn, 1);
    NVIC_EnableIRQ(TIM2_IRQn);

    /* Enable PC13 (Blue button) interrupt */
    NVIC_SetPriority(EXTI15_10_IRQn, 1);
    NVIC_EnableIRQ(EXTI15_10_IRQn);

    while (1) {
    };
}

/**
 * @brief  TIM2 Interrupt Handler
 * @note   This name must match the one in the Startup Assembly file's Vector Table.
 */
void TIM2_IRQHandler(void) {
    /* Capture latency: How many periods have passed since we hit the ARR limit? */
    end_time = DWT->CYCCNT;
    actual_period = end_time - start_time;

    /* Set end time as the new start time to normalize the values */
    start_time = end_time;

    /* Calculate the jitter */
    target_period = 5399 * 1499;
    jitter = (int32_t)actual_period - (int32_t)target_period;

    /* Clear the Update Interrupt Flag!
       If we don't do this, the CPU will stay in an infinite interrupt loop. */
    TIM2->SR &= ~TIM_SR_UIF;

    /* Toggle the output of PA0, PA5 and PB3 */
    GPIOA->ODR ^= GPIO_ODR_OD5;
    GPIOA->ODR ^= GPIO_ODR_OD0;
    GPIOB->ODR ^= GPIO_ODR_OD3;
}

void EXTI15_10_IRQHandler(void) {
    /* Disable clock signal to the GPIOB to freeze PB3 */
    RCC->AHB1ENR ^= RCC_AHB1ENR_GPIOBEN;

    // 2. THE JITTER GENERATOR: 
    // This wastes about 50,000 to 100,000 cycles.
    for(volatile int i = 0; i < 20000; i++);

    /* Disable the interrupt flag by setting it to 1*/
    EXTI->PR |= EXTI_PR_PR13;
}

/* Stub for -nostdlib compilation to satisfy the Reset_Handler in startup_stm32f411xe.s */
void __libc_init_array(void) { /* Empty stub */ }
