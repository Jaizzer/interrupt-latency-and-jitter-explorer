#include "stm32f411xe.h"

int main(void) {
    // Enable CPU timer monitoring
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;

    RCC->AHB1ENR |= RCC_APB1ENR_TIM2EN;
    TIM2->PSC |= 15;
    TIM2->ARR |= 999;
    TIM2->DIER |= TIM_DIER_UIE;
    TIM2->CR1 |= TIM_CR1_CEN;
    NVIC_EnableIRQ(TIM2_IRQn);
    NVIC_SetPriority(TIM2_IRQn, 1);

    while (1) {
    };
}