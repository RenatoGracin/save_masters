/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: pdist.c
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

/* Include Files */
#include "pdist.h"
#include "Calc_Dunn_Index_emxutil.h"
#include "Calc_Dunn_Index_types.h"
#include "rt_nonfinite.h"
#include "scanfornan.h"
#include <math.h>

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *Xin
 *                emxArray_real_T *Y
 * Return Type  : void
 */
void pdist(const emxArray_real_T *Xin, emxArray_real_T *Y)
{
  emxArray_boolean_T *logIndX;
  emxArray_real_T *X;
  const double *Xin_data;
  double ii;
  double qq;
  double tempSum;
  double tempSum_tmp;
  double *X_data;
  double *Y_data;
  int b_loop_ub;
  int i;
  int i1;
  int jj;
  int kk;
  int loop_ub;
  int nd;
  int nx;
  int px;
  boolean_T *logIndX_data;
  Xin_data = Xin->data;
  emxInit_real_T(&X, 2);
  nx = Xin->size[0];
  px = Xin->size[1];
  nd = Xin->size[0] * (Xin->size[0] - 1) / 2;
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
  emxInit_boolean_T(&logIndX);
  scanfornan(X, Xin->size[0], Xin->size[1], logIndX);
  logIndX_data = logIndX->data;
  i = Y->size[0] * Y->size[1];
  Y->size[0] = 1;
  Y->size[1] = nd;
  emxEnsureCapacity_real_T(Y, i);
  Y_data = Y->data;
  for (i = 0; i < nd; i++) {
    Y_data[i] = rtNaN;
  }
  nd--;
#pragma omp parallel for num_threads(omp_get_max_threads()) private(           \
    qq, ii, tempSum, jj, tempSum_tmp)

  for (kk = 0; kk <= nd; kk++) {
    tempSum = 0.0;
    ii = (((double)nx - 2.0) -
          floor(sqrt((-8.0 * (((double)kk + 1.0) - 1.0) +
                      4.0 * (double)nx * ((double)nx - 1.0)) -
                     7.0) /
                    2.0 -
                0.5)) +
         1.0;
    qq = (double)nx - ii;
    qq = ((((double)kk + 1.0) + ii) - (double)nx * ((double)nx - 1.0) / 2.0) +
         qq * (qq + 1.0) / 2.0;
    if (logIndX_data[(int)ii - 1] && logIndX_data[(int)qq - 1]) {
      for (jj = 0; jj < px; jj++) {
        tempSum_tmp = X_data[jj + X->size[0] * ((int)ii - 1)] -
                      X_data[jj + X->size[0] * ((int)qq - 1)];
        tempSum += tempSum_tmp * tempSum_tmp;
      }
      Y_data[kk] = sqrt(tempSum);
    }
  }
  emxFree_boolean_T(&logIndX);
  emxFree_real_T(&X);
}

/*
 * File trailer for pdist.c
 *
 * [EOF]
 */
