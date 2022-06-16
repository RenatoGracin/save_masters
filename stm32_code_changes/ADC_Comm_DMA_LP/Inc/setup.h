#ifndef __HAL_H
#define __HAL_H
#include "stm32l4xx_hal.h"
#endif

#define ENV_START_MEAS 	0x062C 
#define ENV_ADDR				0x44

#define ENV_WRITE_MODE() I2C1->CR2 &= ~((0x04<<16) | (0x01<<10))
#define ENV_READ_MODE() I2C1->CR2 |= ((0x06<<16) | (0x01<<10))
#define ENV_I2C_START() I2C1->CR2 |= (0x01<<13)

#define VBAT_VALUE	ADC1->DR

#define VBAT_ADC_DEEPSLEEP() 			\
	do {														\
		ADC1->CR |= 	(0x01<<1);			\
		ADC1->CR |= 	(0x01<<29);			\
	} while(0)	
	
#define VBAT_ADC_REG_ENABLE() 		\
	do {														\
		ADC1->CR &=  ~(0x01<<29);			\
		ADC1->CR |= 	(0x01<<28);			\
	} while(0)

#define VBAT_ADC_ENABLE() ADC1->CR |= 0x01;

	
#define VBAT_ADC_MEAS_START(cal) 	\
	do {														\
		ADC1->CALFACT = (cal);				\
		ADC1->CR |= (0x01<<2);				\
	} while(0)
	
	
#define N_BUF 32
#define DMA_BUF_SIZE 1024
#define SD_BUF_SIZE (DMA_BUF_SIZE + 2)	//2 for timestamp
#define ENV_BUF_SIZE	5	//2 for timestamp, 1 each for temp, humidity and battery
#define BUF_PER_PACKET 4


#define ADS_SDO_WR_INSTR 0x0A
#define ADS_SDO_RD_INSTR 0x09

// Address
#define ADS_PD_CNTL 0x010
#define ADS_SDI_CNTL 0x014
#define ADS_SDO_CNTL 0x018
#define ADS_DATA_CNTL 0x01c

#define ADS_SDO_CNTL_VALUE 0x0C
// Number of consecutive failed I2C communication before calling Error_Handler()
#define I2C_TIMEOUT 10

// How often will there be temperature and humidity measure ?
#define SENSIRION_MEASURE_PERIOD 60 // (seconds)

// How often will there be ADC acquisition ? // not used here mode
#define ADC_MEASURE_FREQUENCY_DIVIDER 2 // freq = 7.5 / (Divider + 1) MHz

// Flags for ITs
#define FLAG_SET 1
#define FLAG_RESET 0

// GPIO Pins
#define ADC_REF_ENABLE HAL_GPIO_WritePin(GPIOE, GPIO_PIN_8, GPIO_PIN_SET)
#define ADC_REF_DISABLE HAL_GPIO_WritePin(GPIOE, GPIO_PIN_8, GPIO_PIN_RESET)

#define AFE_AMP_ENABLE GPIOE->ODR |= (1<<9);
#define AFE_AMP_DISABLE GPIOE->ODR &= ~(1<<9);

//      When CS is configured as GPIO
#define ADC_CSSDO_ACTIVE GPIOA->ODR &= ~GPIO_PIN_2 //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_2, GPIO_PIN_RESET)
#define ADC_CSSDO_IDLE GPIOA->ODR |= GPIO_PIN_2 //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_2, GPIO_PIN_SET)

#define ADC_RESET_ENABLE HAL_GPIO_WritePin(GPIOA, GPIO_PIN_1, GPIO_PIN_RESET)
#define ADC_RESET_DISABLE HAL_GPIO_WritePin(GPIOA, GPIO_PIN_1, GPIO_PIN_SET)

#define ADC_SPI_MUX_SDO0 HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_RESET)
#define ADC_SPI_MUX_SDI HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, GPIO_PIN_SET)

#define ADS_READY HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_5)

void REG_GPIO_Init(void);
void REG_TIM2_Init(void);
void REG_LPTIM1_Init(void);
void REG_LPTIM2_Init(void);
void REG_OCTOSPI_Init(uint16_t *buffer);
void REG_I2C1_Init(uint8_t *data_buffer, uint8_t *command_buffer);
void REG_BAT_ADC_Init(void);
void REG_ADS_Init(void);
void REG_LPUART1_Init(void);
void MX_SDMMC1_SD_Init(void);
void MX_DMA_Init(void);
