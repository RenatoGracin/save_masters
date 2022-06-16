cmake_minimum_required(VERSION 3.0.0)

project(masters VERSION 0.1.0)

# add_compile_definitions(USE_HAL_DRIVER STM32L4R7xx)
add_compile_definitions(WINDOWS_TESTING USE_HAL_DRIVER STM32L4R7xx ARM_ALL_FFT_TABLES)

message(${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Inc
                    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Include
                    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Inc
                    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Include
                    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/Device/ST/STM32L4xx/Include
                    ${CMAKE_CURRENT_SOURCE_DIR}/Middlewares/Third_Party/FatFs/src
                    )

add_executable(masters  ${CMAKE_CURRENT_SOURCE_DIR}/Src/main.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Src/optics.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Src/scheduler.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/CommonTables/arm_const_structs.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/CommonTables/arm_common_tables.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/TransformFunctions/arm_bitreversal2.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/TransformFunctions/arm_cfft_radix8_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/TransformFunctions/arm_rfft_fast_init_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/TransformFunctions/arm_cfft_init_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/TransformFunctions/arm_cfft_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/TransformFunctions/arm_rfft_fast_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/ComplexMathFunctions/arm_cmplx_mag_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/BasicMathFunctions/arm_mult_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/BasicMathFunctions/arm_mult_f32.c
                        ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/CMSIS/DSP/Source/BasicMathFunctions/arm_scale_f32.c

                        # ${CMAKE_CURRENT_SOURCE_DIR}/Src/fatfs.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Src/setup.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Src/stm32l4xx_hal_msp.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Src/stm32l4xx_it.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Src/system_stm32l4xx.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_lptim.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_ospi.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ramfunc.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_gpio.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_cortex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_exti.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_lptim.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_ospi.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_tim_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_i2c_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_rcc_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_flash_ramfunc.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_gpio.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_dma_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_pwr_ex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_cortex.c
                        # ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/STM32L4xx_HAL_Driver/Src/stm32l4xx_hal_exti.c
                        )

# include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Inc)