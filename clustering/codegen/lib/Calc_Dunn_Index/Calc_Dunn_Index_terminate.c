/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: Calc_Dunn_Index_terminate.c
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

/* Include Files */
#include "Calc_Dunn_Index_terminate.h"
#include "Calc_Dunn_Index_data.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : void
 * Return Type  : void
 */
void Calc_Dunn_Index_terminate(void)
{
  omp_destroy_nest_lock(&Calc_Dunn_Index_nestLockGlobal);
  isInitialized_Calc_Dunn_Index = false;
}

/*
 * File trailer for Calc_Dunn_Index_terminate.c
 *
 * [EOF]
 */
