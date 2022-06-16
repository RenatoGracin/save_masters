#include "main.h"
#include "stm32l4xx_it.h"

#define ADC_CSSDO_IDLE GPIOA->ODR |= GPIO_PIN_2
#define ADC_CSSDO_ACTIVE GPIOA->ODR &= ~GPIO_PIN_2


extern SD_HandleTypeDef hsd1;
extern uint8_t wkup;
extern uint32_t n_btw;
uint32_t tstamp = 0;
uint32_t periods = 0;
uint32_t trig_idx = 0;

uint16_t ev_per_hr = 0;
uint8_t ev_per_hr_lock = 0;

extern uint16_t event_dma_buffer[2][SD_BUF_SIZE];

//Default callbacks
void NMI_Handler(void)
{
  /* USER CODE BEGIN NonMaskableInt_IRQn 0 */

  /* USER CODE END NonMaskableInt_IRQn 0 */
  /* USER CODE BEGIN NonMaskableInt_IRQn 1 */

  /* USER CODE END NonMaskableInt_IRQn 1 */
}


void HardFault_Handler(void)
{
  /* USER CODE BEGIN HardFault_IRQn 0 */

  /* USER CODE END HardFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_HardFault_IRQn 0 */
    /* USER CODE END W1_HardFault_IRQn 0 */
  }
}


void MemManage_Handler(void)
{
  /* USER CODE BEGIN MemoryManagement_IRQn 0 */

  /* USER CODE END MemoryManagement_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_MemoryManagement_IRQn 0 */
    /* USER CODE END W1_MemoryManagement_IRQn 0 */
  }
}


void BusFault_Handler(void)
{
  /* USER CODE BEGIN BusFault_IRQn 0 */

  /* USER CODE END BusFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_BusFault_IRQn 0 */
		HAL_Delay(250);
    /* USER CODE END W1_BusFault_IRQn 0 */
  }
}


void UsageFault_Handler(void)
{
  /* USER CODE BEGIN UsageFault_IRQn 0 */

  /* USER CODE END UsageFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_UsageFault_IRQn 0 */
    /* USER CODE END W1_UsageFault_IRQn 0 */
  }
}


void SVC_Handler(void)
{
  /* USER CODE BEGIN SVCall_IRQn 0 */

  /* USER CODE END SVCall_IRQn 0 */
  /* USER CODE BEGIN SVCall_IRQn 1 */

  /* USER CODE END SVCall_IRQn 1 */
}


void DebugMon_Handler(void)
{
  /* USER CODE BEGIN DebugMonitor_IRQn 0 */

  /* USER CODE END DebugMonitor_IRQn 0 */
  /* USER CODE BEGIN DebugMonitor_IRQn 1 */

  /* USER CODE END DebugMonitor_IRQn 1 */
}
void PendSV_Handler(void)
{
  /* USER CODE BEGIN PendSV_IRQn 0 */

  /* USER CODE END PendSV_IRQn 0 */
  /* USER CODE BEGIN PendSV_IRQn 1 */

  /* USER CODE END PendSV_IRQn 1 */
}
void SysTick_Handler(void)
{
  /* USER CODE BEGIN SysTick_IRQn 0 */

  /* USER CODE END SysTick_IRQn 0 */
  HAL_IncTick();
  /* USER CODE BEGIN SysTick_IRQn 1 */

  /* USER CODE END SysTick_IRQn 1 */
}





uint16_t *dma_buff_ptr = event_dma_buffer[0];
uint8_t read_idx;
extern uint16_t *write_buffer;
//the tasks added to 
extern task_s write_env_task, write_meas_task, write_buffs_task, read_ev_task;
extern uint32_t meas_fp, env_fp;
extern volatile uint32_t sd_write_flag;
extern buffer_s dma_ev_buffer, sigfox_msg_buffer;


uint8_t rec_char[64] = {0};
extern uint8_t *sigfox_msg_ptr;
extern uint32_t sigfox_write_flag;
int char_ctr = 0;
void LPUART1_IRQHandler(void){
	if (LPUART1->ISR & (1<<27)){		//Tx fifo empty
		if (sigfox_msg_ptr == NULL){
			sigfox_write_flag |= SIGFOX_UART_DONE_FLAG;
			LPUART1->CR3 &= ~(1<<23);
		}
		while(sigfox_msg_ptr != NULL && (LPUART1->ISR & (1<<7))){
			LPUART1->TDR = *sigfox_msg_ptr;
			sigfox_msg_ptr = *sigfox_msg_ptr == '\n'?NULL:sigfox_msg_ptr+1;
		}
	}
	if (LPUART1->ISR & (1<<26)){		//Rx fifo threshold
		while(LPUART1->ISR & (1<<5)){
			rec_char[char_ctr++] = LPUART1->RDR;
			char_ctr = char_ctr%64;
		if (rec_char[char_ctr-1] == '\n'){
			rec_char[char_ctr++] = '\n';
		}
		}
}
}
void DMA2_Channel3_IRQHandler(void){
		DMA2->IFCR = DMA_ISR_GIF3;
		DMA2_Channel3->CCR &= ~(1<<0);
	LPUART1->CR3 &= ~(1<<7);
}


//DMA1 is used for transfering data read from the ADC
//ISR for transfer complete and half-transfer
//queues the write_buffs_task which copies the data to 2 buffers, for calculating the FFT and writing to SD
void DMA1_Channel1_IRQHandler(void){	//Half-Transfer!
//	static uint8_t data_cnt = 0;
	
	if (DMA1->ISR & (DMA_IT_TC | DMA_IT_HT)){
		tstamp = periods * 10000 + 2*LPTIM1->CNT / 5;
		if (DMA1->ISR & DMA_IT_HT) {		
			DMA1->IFCR = DMA_ISR_HTIF1;
			*(uint32_t *)&dma_buff_ptr[256] = tstamp;
			write_to_buffer(&dma_ev_buffer, (uint8_t *)dma_buff_ptr, 0);
			while(ev_per_hr_lock);
			ev_per_hr_lock = 1;
			ev_per_hr++;
			ev_per_hr_lock = 0;
			
			//write_buffs_task.args = (void *)dma_buff_ptr;
			//queue_task(write_buffs_task);
		}
		if (DMA1->ISR & DMA_IT_TC) {
			DMA1->IFCR = DMA_ISR_TCIF1;
			TIM2->CNT = 0;
			OCTOSPI1->FCR = HAL_OSPI_FLAG_TE | HAL_OSPI_FLAG_TC;
			if(trig_idx && trig_idx > 258){
				trig_idx = trig_idx<(DMA_BUF_SIZE - 258)? trig_idx : (DMA_BUF_SIZE-258);
				*(uint32_t *)&dma_buff_ptr[trig_idx + 256] = tstamp;
				write_to_buffer(&dma_ev_buffer, (uint8_t *)&dma_buff_ptr[trig_idx], 0);
				while(ev_per_hr_lock);
				ev_per_hr_lock = 1;
				ev_per_hr++;
				ev_per_hr_lock = 0;
				//write_buffs_task.args = (void *)&dma_buff_ptr[trig_idx];
				//queue_task(write_buffs_task);
			}
		
			dma_buff_ptr = dma_buff_ptr == event_dma_buffer[0]? event_dma_buffer[1] : event_dma_buffer[0];
			DMA1_Channel1->CMAR = (uint32_t)dma_buff_ptr;
			TIM2->CCER &= ~(0x01<<13);
		}
		DMA1->IFCR = DMA_ISR_GIF1;
	}
}

extern uint8_t env_dma_buffer[6];
extern uint16_t batt_voltage;
extern uint32_t env_tstamp;
extern buffer_s env_buffer;


//DMA2_Channel1 is used for transfering data read from the environmental sensor 
void DMA2_Channel1_IRQHandler(void){
	static uint16_t env[5];
	static uint8_t sigfox_msg[13] = {0};
	uint16_t temp, rh, vbatt;
	uint32_t tstamp;
	//Kada je spremno ocitanje
	
	DMA2->IFCR = DMA_ISR_GIF1;
	
	tstamp = periods * 10000 + LPTIM1->CNT / 5;
	temp = __REVSH(*(uint16_t *)&env_dma_buffer[0]);
	rh = __REVSH(*(uint16_t *)&env_dma_buffer[3]);
	vbatt = VBAT_VALUE;
	
	*(uint32_t *)env = tstamp;
	env[2] = temp;
	env[3] = rh;
	env[4] = vbatt;
	write_to_buffer(&env_buffer, (uint8_t *)env, 0);
	
	uint32_t tstamp_sigfox = tstamp/100; //U sekunde
	
	sigfox_msg[0] = 11;
	sigfox_msg[1] = (tstamp_sigfox&0x0ff00000)>>20;
	sigfox_msg[2] = (tstamp_sigfox&0x000ff000)>>12;
	sigfox_msg[3] = (tstamp_sigfox&0x00000ff0)>>4;
	sigfox_msg[4] = ((tstamp_sigfox&0x0000000f)<<4)|((vbatt&0x0f00)>>8);
	sigfox_msg[5] = vbatt&0x00ff;
	sigfox_msg[6] = (temp&0xff00)>>8;
	sigfox_msg[7] = (temp&0x00ff);
	sigfox_msg[8] = (rh&0xff00)>>8;
	sigfox_msg[9] = (rh&0x00ff);
	while(ev_per_hr_lock);
	ev_per_hr_lock = 1;
	sigfox_msg[10] = (ev_per_hr&0xff00)>>8;
	sigfox_msg[11] = (ev_per_hr&0x00ff);
	ev_per_hr = 0;
	ev_per_hr_lock = 0;
	
	write_to_buffer(&sigfox_msg_buffer, sigfox_msg, 0);
	
	ENV_WRITE_MODE();			//Pripremi za pisanje komande
	VBAT_ADC_DEEPSLEEP();
}

//DMA2_Channel2 is used for sending commands to the environmental sensor
void DMA2_Channel2_IRQHandler(void){
	//Pokreni citanje
	DMA2->IFCR = DMA_ISR_GIF2;
	ENV_READ_MODE();
	LPTIM2->CR = LPTIM2->CR | 0x01<<1;	//Start LPTIM2 in oneshot mode 
}

//EXTI0 is caused by a rising edge of the trigger input from the ADC
void EXTI0_IRQHandler(void){	//If there is an ongoing transmission, save the current DMA_CNDTR
	EXTI->PR1 = 0xFF;
	if (!(trig_idx = DMA_BUF_SIZE + 2 - DMA1_Channel1->CNDTR)){
		TIM2->CCER |= (0x01<<13);
		OCTOSPI1->IR = OCTOSPI1->IR;
	}
}

//SDMMC1_IRQHandler is called by any interrupt that has anything to do with the SD card
void SDMMC1_IRQHandler(void){
	HAL_SD_IRQHandler(&hsd1);
}

//This callback is called when writing to SD finishes
void BSP_SD_WriteCpltCallback(void)
{
	sd_write_flag |= 0x01;
	SDMMC1->ICR |= 0xFFFFFFFF;
}

//LPTIM1 is used for taking environmental measurements every 20 minutes
void LPTIM1_IRQHandler(void){
	static uint32_t sigfox_ctr = 10;
	LPTIM1->ICR |= (0x01<<1);
	//read from SD 
//  queue_task(read_ev_task);
	if (periods % 36 == 0){	//12 -> 20 min (za period od 100 sekundi)
	//if (periods % 150 == 0) {	//150 -> 5 min (za period od 2 sekunde)
	//if (periods % 300 == 0) {	//300 -> 5 min (za period od 1 sekunde)
		ENV_I2C_START();
		VBAT_ADC_REG_ENABLE();
	}
	//if ((sigfox_write_flag & SIGFOX_TIMER_FLAG) == 0){
	//	if (sigfox_ctr > 0)
	//			sigfox_ctr--;
	//	else{
	//		sigfox_write_flag |= SIGFOX_TIMER_FLAG;
	//		sigfox_ctr = 10;
	//	}
	//}
	periods += 1;
}

//LPTIM2 is used to make sure that enough time has passed for the ENV measurement
void LPTIM2_IRQHandler(void){
	LPTIM2->ICR |= (0x01<<1);
	ENV_I2C_START();
	VBAT_ADC_ENABLE();
}
extern uint16_t cal_factor_s;

//Start the battery level measurement after the ADC has been enabled
void ADC1_IRQHandler(void){
	ADC1->ISR |= 0x01;
	VBAT_ADC_MEAS_START(cal_factor_s);
}
