/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: scanfornan.c
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

/* Include Files */
#include "scanfornan.h"
#include "Calc_Dunn_Index_emxutil.h"
#include "Calc_Dunn_Index_types.h"
#include "rt_nonfinite.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *X
 *                double px
 * Return Type  : boolean_T
 */
boolean_T b_scanfornan(const emxArray_real_T *X, double px)
{
  const double *X_data;
  int jj;
  boolean_T exitg1;
  boolean_T nanflag;
  X_data = X->data;
  nanflag = false;
  jj = 0;
  exitg1 = false;
  while ((!exitg1) && (jj <= (int)px - 1)) {
    if (rtIsNaN(X_data[jj])) {
      nanflag = true;
      exitg1 = true;
    } else {
      jj++;
    }
  }
  return !nanflag;
}

/*
 * Arguments    : const emxArray_real_T *X
 *                double nx
 *                double px
 *                emxArray_boolean_T *nanobs
 * Return Type  : void
 */
void scanfornan(const emxArray_real_T *X, double nx, double px,
                emxArray_boolean_T *nanobs)
{
  const double *X_data;
  int i;
  int jj;
  int loop_ub_tmp;
  int qq;
  boolean_T exitg1;
  boolean_T nanflag;
  boolean_T *nanobs_data;
  X_data = X->data;
  i = nanobs->size[0] * nanobs->size[1];
  nanobs->size[0] = 1;
  loop_ub_tmp = (int)nx;
  nanobs->size[1] = (int)nx;
  emxEnsureCapacity_boolean_T(nanobs, i);
  nanobs_data = nanobs->data;
  for (i = 0; i < loop_ub_tmp; i++) {
    nanobs_data[i] = true;
  }
  loop_ub_tmp = (int)nx - 1;
#pragma omp parallel for num_threads(omp_get_max_threads()) private(           \
    nanflag, jj, exitg1)

  for (qq = 0; qq <= loop_ub_tmp; qq++) {
    nanflag = false;
    jj = 0;
    exitg1 = false;
    while ((!exitg1) && (jj <= (int)px - 1)) {
      if (rtIsNaN(X_data[jj + X->size[0] * qq])) {
        nanflag = true;
        exitg1 = true;
      } else {
        jj++;
      }
    }
    if (nanflag) {
      nanobs_data[qq] = false;
    }
  }
}

/*
 * File trailer for scanfornan.c
 *
 * [EOF]
 */
