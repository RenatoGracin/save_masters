/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Calc_Dunn_Index_api.h
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

#ifndef _CODER_CALC_DUNN_INDEX_API_H
#define _CODER_CALC_DUNN_INDEX_API_H

/* Include Files */
#include "emlrt.h"
#include "tmwtypes.h"
#include <string.h>

/* Type Definitions */
#ifndef struct_emxArray_real_T
#define struct_emxArray_real_T
struct emxArray_real_T {
  real_T *data;
  int32_T *size;
  int32_T allocatedSize;
  int32_T numDimensions;
  boolean_T canFreeData;
};
#endif /* struct_emxArray_real_T */
#ifndef typedef_emxArray_real_T
#define typedef_emxArray_real_T
typedef struct emxArray_real_T emxArray_real_T;
#endif /* typedef_emxArray_real_T */

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
real_T Calc_Dunn_Index(emxArray_real_T *dataset, emxArray_real_T *cluster_ind);

void Calc_Dunn_Index_api(const mxArray *const prhs[2], const mxArray **plhs);

void Calc_Dunn_Index_atexit(void);

void Calc_Dunn_Index_initialize(void);

void Calc_Dunn_Index_terminate(void);

void Calc_Dunn_Index_xil_shutdown(void);

void Calc_Dunn_Index_xil_terminate(void);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_Calc_Dunn_Index_api.h
 *
 * [EOF]
 */
