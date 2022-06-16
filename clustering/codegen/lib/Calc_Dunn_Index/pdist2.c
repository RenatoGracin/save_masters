/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: pdist2.c
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

/* Include Files */
#include "pdist2.h"
#include "Calc_Dunn_Index_emxutil.h"
#include "Calc_Dunn_Index_types.h"
#include "rt_nonfinite.h"
#include "scanfornan.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *Xin
 *                const emxArray_real_T *Yin
 *                emxArray_real_T *D
 * Return Type  : void
 */
void pdist2(const emxArray_real_T *Xin, const emxArray_real_T *Yin,
            emxArray_real_T *D)
{
  emxArray_boolean_T *logIndX;
  emxArray_real_T *X;
  emxArray_real_T *Y;
  const double *Xin_data;
  const double *Yin_data;
  double tempSum;
  double tempSum_tmp;
  double *D_data;
  double *X_data;
  double *Y_data;
  int b_loop_ub;
  int i;
  int i1;
  int loop_ub;
  boolean_T *logIndX_data;
  Yin_data = Yin->data;
  Xin_data = Xin->data;
  if (Xin->size[0] == 0) {
    D->size[0] = 0;
  } else {
    i = D->size[0];
    D->size[0] = Xin->size[0];
    emxEnsureCapacity_real_T(D, i);
    D_data = D->data;
    loop_ub = Xin->size[0];
    for (i = 0; i < loop_ub; i++) {
      D_data[i] = rtNaN;
    }
    emxInit_real_T(&X, 2);
    i = X->size[0] * X->size[1];
    X->size[0] = Xin->size[1];
    X->size[1] = Xin->size[0];
    emxEnsureCapacity_real_T(X, i);
    X_data = X->data;
    loop_ub = Xin->size[0];
    for (i = 0; i < loop_ub; i++) {
      b_loop_ub = Xin->size[1];
      for (i1 = 0; i1 < b_loop_ub; i1++) {
        X_data[i1 + X->size[0] * i] = Xin_data[i + Xin->size[0] * i1];
      }
    }
    emxInit_real_T(&Y, 1);
    i = Y->size[0];
    Y->size[0] = Yin->size[1];
    emxEnsureCapacity_real_T(Y, i);
    Y_data = Y->data;
    loop_ub = Yin->size[1];
    for (i = 0; i < loop_ub; i++) {
      Y_data[i] = Yin_data[i];
    }
    emxInit_boolean_T(&logIndX);
    scanfornan(X, Xin->size[0], Xin->size[1], logIndX);
    logIndX_data = logIndX->data;
    if (b_scanfornan(Y, Xin->size[1])) {
      i = Xin->size[0];
      for (loop_ub = 0; loop_ub < i; loop_ub++) {
        if (logIndX_data[loop_ub]) {
          tempSum = 0.0;
          i1 = Xin->size[1];
          for (b_loop_ub = 0; b_loop_ub < i1; b_loop_ub++) {
            tempSum_tmp =
                X_data[b_loop_ub + X->size[0] * loop_ub] - Y_data[b_loop_ub];
            tempSum += tempSum_tmp * tempSum_tmp;
          }
          D_data[loop_ub] = sqrt(tempSum);
        }
      }
    }
    emxFree_boolean_T(&logIndX);
    emxFree_real_T(&Y);
    emxFree_real_T(&X);
  }
}

/*
 * File trailer for pdist2.c
 *
 * [EOF]
 */
