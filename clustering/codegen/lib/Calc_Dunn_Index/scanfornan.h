/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: scanfornan.h
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

#ifndef SCANFORNAN_H
#define SCANFORNAN_H

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
boolean_T b_scanfornan(const emxArray_real_T *X, double px);

void scanfornan(const emxArray_real_T *X, double nx, double px,
                emxArray_boolean_T *nanobs);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for scanfornan.h
 *
 * [EOF]
 */
