/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

#define BUFF_TIMER_SWITCH (0x01<<0)
#define BUFF_TIMER_RESET	(0x01<<1)
#define BUFF_BUFFER_READY (0x01<<2)

#define SD_DMA_FLAG 	(0x01<<0)
#define SD_DONE_FLAG	(0x01<<1)
#define SD_SYNC_MEAS_FLAG 	(0x01<<2)
#define SD_SYNC_ENV_FLAG 	(0x01<<3)
#define SD_SYNC_FFT_FLAG 	(0x01<<4)
// TODO: Add FLAG support for other feature files
#define SD_SYNC_PEAK_FLAG (0x01<<5)
#define SD_SYNC_CLUST_FLAG (0x01<<6)


#define SIGFOX_TIMER_FLAG (0x01<<0)
#define SIGFOX_UART_DONE_FLAG (0x01<<1)
#define SIGFOX_RDY_FLAG SIGFOX_TIMER_FLAG|SIGFOX_UART_DONE_FLAG

/* Includes ------------------------------------------------------------------*/
#ifndef WINDOWS_TESTING
#include "setup.h"

#include "stm32l4xx_hal.h"
#else
#define DMA_BUF_SIZE 1024
#define SD_BUF_SIZE (DMA_BUF_SIZE + 2)	//2 for timestamp
#define ENV_START_MEAS 	0x062C 
#endif

#include "scheduler.h"


void Error_Handler(void);

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
