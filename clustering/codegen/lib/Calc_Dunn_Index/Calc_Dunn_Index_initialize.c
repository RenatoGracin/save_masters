/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: Calc_Dunn_Index_initialize.c
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

/* Include Files */
#include "Calc_Dunn_Index_initialize.h"
#include "Calc_Dunn_Index_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : void
 */
void Calc_Dunn_Index_initialize(void)
{
  omp_init_nest_lock(&Calc_Dunn_Index_nestLockGlobal);
  isInitialized_Calc_Dunn_Index = true;
}

/*
 * File trailer for Calc_Dunn_Index_initialize.c
 *
 * [EOF]
 */
