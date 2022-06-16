/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_Calc_Dunn_Index_mex.h
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

#ifndef _CODER_CALC_DUNN_INDEX_MEX_H
#define _CODER_CALC_DUNN_INDEX_MEX_H

/* Include Files */
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Function Declarations */
MEXFUNCTION_LINKAGE void mexFunction(int32_T nlhs, mxArray *plhs[],
                                     int32_T nrhs, const mxArray *prhs[]);

emlrtCTX mexFunctionCreateRootTLS(void);

void unsafe_Calc_Dunn_Index_mexFunction(int32_T nlhs, mxArray *plhs[1],
                                        int32_T nrhs, const mxArray *prhs[2]);

#ifdef __cplusplus
}
#endif

#endif
/*
 * File trailer for _coder_Calc_Dunn_Index_mex.h
 *
 * [EOF]
 */
