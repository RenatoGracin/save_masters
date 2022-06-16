#include<setup.h>

OSPI_HandleTypeDef hospi1;
DMA_HandleTypeDef hdma_octospi1;
SD_HandleTypeDef hsd1;
TIM_HandleTypeDef htim2;
I2C_HandleTypeDef hi2c1;

void REG_LPUART1_Init(void){
	//GPIO, CLK
	__HAL_RCC_GPIOC_CLK_ENABLE();
	__HAL_RCC_LPUART1_CLK_ENABLE();
	
	GPIOC->AFR[0] |= (0x88);	//PC0 & PC1 AF8
	GPIOC->MODER &= ~((0x01<<2)|(0x01<<0)); //Alternate function mode
	GPIOC->OSPEEDR	|= 	(0x03<<2) | (0x03);		//Very high speed
	//DMA Ch3 -> TX
/*	DMA2_Channel3->CCR |= (0x01<<12) 	| 	// Medium priority
												(0x01<<7)  	| 	//Memory increment mode
												(0x01<<5)		|		//Circular mode
												(0x01<<4)		|		//Memory -> Peripheral
												(0x05<<1);			//TC&TE Interrupt
	
	DMA2_Channel3->CNDTR = 16;			//AT$SF=[16 byte message]
	DMA2_Channel3->CPAR = (uint32_t)&LPUART1->TDR;
	
	DMAMUX1_Channel9->CCR = DMA_REQUEST_LPUART1_TX;
	DMAMUX1_ChannelStatus->CFR = 0x01<<9;
*/	
	
	LPUART1->CR1 |= (1<<29);// | 				//FIFO Enable
							//		(1<<6);					//Transfer complete interrupt enable
	LPUART1->PRESC |= 0x00;
									
	LPUART1->BRR |= 0x369;							//256*lpuartckpres/BRR
	LPUART1->CR3 |= (1<<28)	|		//RX fifo threshold interrupt
									(0<<25) |		//Interrupt when 1/4 of depth (2 bytes -> OK);	
	//							(1<<23) |   //TX fifo threshold interrupt
									(5U<<29)	;		//Interrupt when FIFO empty;
									
	LPUART1->CR1 |= (1<<0); 					//UART Enable
	//LPUART1->CR3 |= (1<<7); 	//DMA Enable TX
									
	LPUART1->ISR |= (1<<6);						//Clear TC flag
	LPUART1->CR1 |= (1<<3)|(1<<2);						//RX & TX Enable
	
	
	
	HAL_NVIC_SetPriority(LPUART1_IRQn, 4, 1);
	HAL_NVIC_EnableIRQ(LPUART1_IRQn);
	
	//HAL_NVIC_SetPriority(DMA2_Channel3_IRQn, 3, 2);
	//HAL_NVIC_EnableIRQ(DMA2_Channel3_IRQn);
	
	//LPUART_CR1 -> word length (8)
	//LPUART_BRR -> Baud rate (9600)
	//LPUART_CR2 -> Stop bits (1)
	//LPUART_CR1 -> UART Enable
	//LPUART_CR3 -> DMA enable
	//LPUART_CR1 -> TX Enable - Send idle frame
	//
	
	
}

void REG_I2C1_Init(uint8_t *data_buffer, uint8_t *command_buffer){
	
	//TODO : GPIO, CLK
	__HAL_RCC_I2C1_CLK_ENABLE();
	
	
	GPIOB->AFR[0] 	|= 	(0x04<<(7*4)) | (0x04<<(6*4)); 		//SCL & SDA Alternate functions 
	GPIOB->MODER 		&= ~((0x01<<(7*2)) | (0x01<<(6*2))); 	//Alternate function mode
	GPIOB->OTYPER 	|= 	(0x01<<7) | (0x01<<6);						//Open drain mode
	GPIOB->OSPEEDR	|= 	(0x03<<(7*2)) | (0x03<<(6*2));		//Very high speed
	
	//SYSCFG->CFGR1 	|= (0x03<<16) ;	//Fm+ on PB6 and PB7
	//TODO : DMA
	//DMA Ch 1 -> RX
	//DMA Ch 2 -> TX

	DMA2_Channel1->CCR |= (0x03<<12)|		//Very high priority
												(0x01<<7)	|		//Memory increment mode
												(0x01<<5) | 	//Circ mode
												(0x05<<1) ;		//TC and TE interrupts
	
	DMA2_Channel1->CNDTR = 6;
	DMA2_Channel1->CPAR = (uint32_t)&I2C1->RXDR;
	DMA2_Channel1->CMAR = (uint32_t)data_buffer;
	
	
	DMA2_Channel2->CCR |= (0x02<<12)|		//High priority
												(0x01<<7)	|		//Memory increment mode
												(0x01<<5) | 	//Circ mode
												(0x01<<4)	|		//Memory to peripheral
												(0x05<<1) ;		//TC and TE interrupts
	
	DMA2_Channel2->CNDTR = 2;
	DMA2_Channel2->CPAR = (uint32_t)&I2C1->TXDR;
	DMA2_Channel2->CMAR = (uint32_t)command_buffer;
	
//	DMAMUX
	DMAMUX1_Channel7->CCR = DMA_REQUEST_I2C1_RX;
	DMAMUX1_Channel8->CCR = DMA_REQUEST_I2C1_TX;

  // Clear the DMAMUX synchro overrun flag 
  DMAMUX1_ChannelStatus->CFR = (0x03<<7);
	
	//PERIHP Initialization
	I2C1->CR1 |=  (0x03<<14)| 	//DMA Rx and Tx
								(0x01<<6)	;		//Transfer Complete interrupt enable
	I2C1->CR2 |= 	(0x01<<25) | 	//Autoend
								(ENV_ADDR<<1);//Slave address
	
	ENV_READ_MODE();	//6 bytes, read transfer (setting the reg for later)
	ENV_WRITE_MODE(); //Write goes first
	
	I2C1->TIMINGR |= 0xF01075FF;	//Taken from CubeMX, 400 kHz fast mode
	
	//Enable(CR1)
	DMA2_Channel1->CCR |= 0x01; 
	DMA2_Channel2->CCR |= 0x01; 
	
	I2C1->CR1 |= (0x01);
}

void REG_TIM2_Init(void){
	
//	HAL_TIM_Base_MspInit 
	
	__HAL_RCC_TIM2_CLK_ENABLE();
	
	
	//PA2, PA5
	GPIOA->AFR[0] |= (0x01<<(5*4)) | (0x01<<(2*4)); 	//Alternate function 1 (TIM2)
	GPIOA->MODER &= ~((0x01<<(5*2)) | (0x01<<(2*2))); //Alternate function mode
	GPIOA->MODER |= (0x02<<(2*2));
	GPIOA->OSPEEDR |= (0x03<<(5*2)) | (0x02<<(2*2));	//High speed

	//PB11
	GPIOB->AFR[1] |= (0x01<<(3*4)); 		//Alternate function 1 (TIM2)
	GPIOB->MODER &= ~(0x01<<(11*2)); 	//Alternate function mode
	GPIOB->OSPEEDR |= (0x03<<(11*2)); 	//High speed
	
//	HAL_TIM_Base_SetConfig
	
	TIM2->ARR = 15;
	TIM2->EGR = TIM_EGR_UG;
	TIM2->PSC = 0x00;
	
	
//	HAL_TIM_SlaveConfigSynchro
	TIM2->SMCR |= (0x05<<4) |			//TI1FP1
								(0x07);					//External clock mode 1
	TIM2->CCER |= (0x0A) |				//Both edges
								(0x01 << 13);		//CH4 active LOW
//	

	TIM2->CCMR2 |=	(0x06 << 4) | (0x06 << 12);	//CH3 & CH4 PWM mode 1
	
	TIM2->CCR3 = 7;
	TIM2->CCR4 = 3;
	
	TIM2->CR1 |= 0x01;												//Enable TIM2
	TIM2->CCER |= (0x01 << 8) | (0x01 << 12);	//Enable CH3 & CH4

}

void REG_LPTIM2_Init(void){
	__HAL_RCC_LPTIM2_CLK_ENABLE();
	
	LPTIM2->IER |= 	(0x01<<1);	// Autoreload match interrupt
	LPTIM2->CFGR |= (0x05<<9)	;	// Prescaler 32 -> 1 kHz clock
	
	LPTIM2->CR |= 	(0x01); 		//Enable
	
	LPTIM2->ARR = 2;
}

void REG_LPTIM1_Init(void){
	__HAL_RCC_LPTIM1_CLK_ENABLE();
	
	LPTIM1->IER |= 	(0x01<<1);	// Autoreload match interrupt
	LPTIM1->CFGR |= (0x07<<9)	;	// Prescaler 128
	
	LPTIM1->CR |= 	(0x00<<4)|	//Reset on read (Disabled for now)
									(0x01); 		//Enable
	
	LPTIM1->ARR = 25600;				//25600 -> 100 sekundi
	
}

void MX_DMA_Init(void)
{
	__HAL_RCC_DMAMUX1_CLK_ENABLE();
	__HAL_RCC_DMA1_CLK_ENABLE();

	__HAL_RCC_DMA2_CLK_ENABLE();
	
	HAL_NVIC_SetPriority(DMA1_Channel1_IRQn, 1, 1);
	HAL_NVIC_EnableIRQ(DMA1_Channel1_IRQn);
	
	HAL_NVIC_SetPriority(DMAMUX1_OVR_IRQn, 0, 0);
	HAL_NVIC_EnableIRQ(DMAMUX1_OVR_IRQn);
	
	HAL_NVIC_SetPriority(DMA2_Channel1_IRQn, 3, 1);
	HAL_NVIC_EnableIRQ(DMA2_Channel1_IRQn);
	
	HAL_NVIC_SetPriority(DMA2_Channel2_IRQn, 3, 2);
	HAL_NVIC_EnableIRQ(DMA2_Channel2_IRQn);
	
}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
void REG_GPIO_Init(void)
{
  /* GPIO Ports Clock Enable */
	__HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();
  __HAL_RCC_GPIOE_CLK_ENABLE();

  /*Configure PA2 pin Output Level (nCS) */
	GPIOA->ODR = 0x0004;
	
//	GPIOA
	/*Configure GPIO pin : PA0 PA1 PA2*/
	GPIOA->MODER &= ~((0x02<<(2*2)) | (0x02<<(1*2)) |	//Outputs
										(0x03));												//Input
//GPIOA->PUPDR |= 0x02; //Pull down
//	SYSCFG->EXTICR[0] |= 0x00;	//PA0 is the default
	EXTI->IMR1 |= 0x01;		//Line 0 INT not masked
	EXTI->RTSR1 |= 0x01; 	//Rising edge
	
	
	
  /*Configure GPIO pin : PB2 */
	GPIOB->MODER &= ~((0x02<<(2*2)));	//Output
//	GPIOE
  /*Configure GPIO pins : PE8 PE9 */
	GPIOE->MODER &= ~((0x02<<(9*2))|(0x02<<(8*2)));	//Outputs
	GPIOE->OSPEEDR |= (0x03<<(9*2))|(0x03<<(8*2));	//Very high speed
}

void REG_OCTOSPI_Init(uint16_t *buffer)
{
	ADC_CSSDO_IDLE;
//MSP
	__HAL_RCC_OSPI1_CLK_ENABLE();

	/**OCTOSPI1 GPIO Configuration    
	PA3     ------> OCTOSPIM_P1_CLK
	PA6     ------> OCTOSPIM_P1_IO3
	PA7     ------> OCTOSPIM_P1_IO2
	PB0     ------> OCTOSPIM_P1_IO1
	PB1     ------> OCTOSPIM_P1_IO0
	*/

 	GPIOA->AFR[0] |= (0xAU<<(7*4)) | (0x0AU<<(6*4)) | (0x0AU<<(3*4)); 	//Alternate function 10 (OCTOSPI)
	GPIOA->MODER &= ~((0x01U<<(7*2))|(0x01U<<(6*2)) | (0x01U<<(3*2))); //Alternate function mode
	GPIOA->OSPEEDR |= (0x03U<<(7*2)) | (0x03U<<(6*2)) | (0x03U<<(3*2));	//Very high speed
	
	GPIOB->AFR[0] |= (0x0A<<(1*4)) | (0x0A);
	GPIOB->MODER &= ~((0x01<<(1*2)) | (0x01));
	GPIOB->OSPEEDR |= (0x03<<(1*2)) | (0x03);


/* USER CODE BEGIN OCTOSPI1_MspInit 1 */
		
//	DMA_Init
	DMA1_Channel1->CCR |= (0x03<<12)|		//Very high priority
												(0x01<<10)|		//16-bit memory size
												(0x02<<8)	|		//32-bit peripheral size
												(0x01<<7)	|		//Memory increment mode
												(0x01<<5) | 	//Circ mode
												(0x07<<1) ;		//TC, HT and TE interrupts
	DMA1_Channel1->CNDTR = DMA_BUF_SIZE + 2;
	DMA1_Channel1->CPAR = (uint32_t)&OCTOSPI1->DR;
	DMA1_Channel1->CMAR = (uint32_t)buffer;
	
//	DMAMUX
	DMAMUX1_Channel0->CCR = DMA_REQUEST_OCTOSPI1;

  // Clear the DMAMUX synchro overrun flag 
  DMAMUX1_ChannelStatus->CFR = 0x01;
	
//	__HAL_LINKDMA(&hospi1, hdma, hdma_octospi1);


//!MSP
//OSPI Init
	OCTOSPI1->DCR1 |= (0x10<<16);		//Device size 16
	OCTOSPI1->DCR2 |= 0x01;					//Prescaler 2	-> 20 MHz with PLLQ clk source
	OCTOSPI1->CR |= (0x03 << 8) |		//FIFO Threshold
									(0x01 <<16)	|		//Transfer error interrupt
									(0x01);					//Enable
//!OSPI Init

}
extern uint16_t cal_factor_s;
void REG_BAT_ADC_Init(void)
{
	__HAL_RCC_ADC_CLK_ENABLE();
	//CH18SEL -> ADCx_CCR
	//ADC1->IER |= (0x01<<2);	//End of conversion interrupt
	//Wakeup procedure
	ADC1->CR  &= ~(0x01<<29);	//Exit deep-power-down mode
	ADC1->CR |= (0x01<<28);		//Enable voltage regulator (Need to wait 20us before enabling ADC)
	
	HAL_Delay(1);
	ADC1->CR |= (0x01U<<31);	//Start calibration
	while(ADC1->CR & (0x01U<<31));
	cal_factor_s = (ADC1->CALFACT & 0x7F);	//Save the calibration factor in case it is needed later
	HAL_Delay(1);
	//TODO: Clock config?
	ADC1_COMMON->CCR |= (0x01<<24) |	//Enable Vbat on channel 18
											(0x03<<16); 	//Synchronous clock divided by 4 (This should probably be changed so we could use a bigger prescaler)
	
	
	
	//TODO;Enable and wait for tstab
	//clear ADRDY, set ADEN, wait until ADRDY=1
	//MUST be done before the next set of registers are configured

	ADC1->CR |= 0x01;		//Enable the ADC
	while(!(ADC1->ISR & 0x01));	//Wait for ADRDY
	ADC1->ISR |= 0x01;	//Clear ADRDY
	
	ADC1->IER |= 0x01;					//Enable the AD Ready interrupt
	ADC1->SMPR2 |= (0x07<<24);	// 650 ADC cycle conversion time ( ~650 us )
	ADC1->SQR1 	|= (18<<6);			//Channel 18 (Vbatt) only one in sequence
	
	VBAT_ADC_DEEPSLEEP();
	//TODO: Trebalo bi staviti ADC u deep-power-down mode nakon svake konverzije
	//Budenje + konverzija bi trebali trajati manje od mjerenja env. senzora, tako da vjerojatno nije problem
	//Ima interrupt za ADRDY, ali ne i za Voltage regulator ->ADRDYIE jedini interrupt
	// 1) Exit DPD Mode and enable voltage reg on trigger
	// 2) Wait for LPTIM2 interrupt and enable the ADC
	// 3) Wait for ADRDY interrupt, inject the calibration factor and start the measurement
	// 4) Go to low power mode when measurement is done
}

void REG_ADS_Init(void)
{
	//RESET the ADS chip
	ADC_REF_ENABLE;
	ADC_RESET_ENABLE;
	HAL_Delay(1);
	ADC_RESET_DISABLE;
	HAL_Delay(50);
	
	ADC_REF_ENABLE;
	ADC_SPI_MUX_SDI;
	HAL_Delay(1);
	ADC_CSSDO_ACTIVE; // pulls down the nCS pin
	
	// see OSPI_RegularCmdTypeDef typedef
	// Configure the ADS to use all 4 bits as SDO outputs
	//COMMAND CONFIG
	/*
	DLR -> 1 byte transfer -> default
	TCR	-> no shift or delay, 0 dummy cycles -> default
	CCR
	IR
	ABR
	AR
	DMAEN
	DR
	*/
	OCTOSPI1->CCR |= 	(0x01<<24)	| 	//data on a single line
										(0x01<<8)		|		//address on a single line
										(0x01);					//instruction on a single line
	OCTOSPI1->IR = ADS_SDO_WR_INSTR;
	OCTOSPI1->AR = ADS_DATA_CNTL;
	OCTOSPI1->DR = 0x01;	//send converted samples

	while(OCTOSPI1->SR & 0x20);	//Wait for BUSY bit to get cleared

	ADC_CSSDO_IDLE; // pulls up the nCS pin
	HAL_Delay(1);
	ADC_CSSDO_ACTIVE;
	
	// The ADC will send data through 4 pins instead of 1 by default
	OCTOSPI1->AR = ADS_SDO_CNTL;
	OCTOSPI1->DR = ADS_SDO_CNTL_VALUE;
	
	while(OCTOSPI1->SR &0x20);
	
	ADC_CSSDO_IDLE;
	HAL_Delay(1);
	ADC_CSSDO_ACTIVE;
	OCTOSPI1->AR = 0x11;	//Unlock PD register
	OCTOSPI1->DR = 0x69;

	while(OCTOSPI1->SR &0x20);
	
	ADC_CSSDO_IDLE;
	HAL_Delay(1);
	ADC_CSSDO_ACTIVE;
	OCTOSPI1->AR = 0x10;	//Enable NAP mode
	OCTOSPI1->DR = 0x02;	
	
	while(OCTOSPI1->SR &0x20);
	ADC_CSSDO_IDLE;
	ADC_SPI_MUX_SDO0;
	
	OCTOSPI1->CR |= (0x01<<28);		 	//indirect-read mode
									
	OCTOSPI1->DLR = 4*(DMA_BUF_SIZE + 2) - 1;
	OCTOSPI1->TCR |= 0x05;					//5 dummy cycles
	OCTOSPI1->CCR = (0x03<<24);			//data on 4 lines
	
	OCTOSPI1->CR |= (0x01<<2);			//DMA enabled
	DMA1_Channel1->CCR |= 0x01; 		//DMA channel enable
	
	AFE_AMP_ENABLE;		//Enable frontend
}

void MX_SDMMC1_SD_Init(void)
{
  hsd1.Instance = SDMMC1;
  hsd1.Init.ClockEdge = SDMMC_CLOCK_EDGE_RISING;
  hsd1.Init.ClockPowerSave = SDMMC_CLOCK_POWER_SAVE_DISABLE;
  hsd1.Init.BusWide = SDMMC_BUS_WIDE_4B;
  hsd1.Init.HardwareFlowControl = SDMMC_HARDWARE_FLOW_CONTROL_ENABLE;
  hsd1.Init.ClockDiv = 0;
  hsd1.Init.Transceiver = SDMMC_TRANSCEIVER_DISABLE;

}
