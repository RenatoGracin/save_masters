/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: Calc_Dunn_Index.h
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

#ifndef CALC_DUNN_INDEX_H
#define CALC_DUNN_INDEX_H

/* Include Files */
#include "Calc_Dunn_Index_types.h"
#include "rtwtypes.h"
#include "omp.h"
#include <stddef.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
extern double Calc_Dunn_Index(const emxArray_real_T *dataset,
                              const emxArray_real_T *cluster_ind);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for Calc_Dunn_Index.h
 *
 * [EOF]
 */
