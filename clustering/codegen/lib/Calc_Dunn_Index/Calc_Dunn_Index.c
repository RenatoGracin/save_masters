/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: Calc_Dunn_Index.c
 *
 * MATLAB Coder version            : 5.3
 * C/C++ source code generated on  : 18-May-2022 07:37:16
 */

/* Include Files */
#include "Calc_Dunn_Index.h"
#include "Calc_Dunn_Index_data.h"
#include "Calc_Dunn_Index_emxutil.h"
#include "Calc_Dunn_Index_initialize.h"
#include "Calc_Dunn_Index_types.h"
#include "pdist.h"
#include "pdist2.h"
#include "rt_nonfinite.h"
#include "unique.h"
#include "rt_nonfinite.h"

/* Function Definitions */
/*
 * Arguments    : const emxArray_real_T *dataset
 *                const emxArray_real_T *cluster_ind
 * Return Type  : double
 */
double Calc_Dunn_Index(const emxArray_real_T *dataset,
                       const emxArray_real_T *cluster_ind)
{
  emxArray_boolean_T *r2;
  emxArray_int32_T *r;
  emxArray_int32_T *r3;
  emxArray_real_T *b_cluster_ind;
  emxArray_real_T *cluster_centroids;
  emxArray_real_T *cluster_data;
  emxArray_real_T *cluster_ids;
  emxArray_real_T *cluster_intradist;
  emxArray_real_T *x;
  const double *cluster_ind_data;
  const double *dataset_data;
  double bsum;
  double dunn_index;
  double ex;
  double y;
  double *cluster_centroids_data;
  double *cluster_data_data;
  double *cluster_ids_data;
  double *cluster_intradist_data;
  int firstBlockLength;
  int hi;
  int i;
  int i1;
  int i2;
  int ib;
  int id_ind;
  int k;
  int lastBlockLength;
  int nblocks;
  int xblockoffset;
  int xi;
  int xpageoffset;
  int *r1;
  boolean_T exitg1;
  boolean_T *r4;
  if (!isInitialized_Calc_Dunn_Index) {
    Calc_Dunn_Index_initialize();
  }
  cluster_ind_data = cluster_ind->data;
  dataset_data = dataset->data;
  /*      cluster_ind(cluster_ind==-1) = []; */
  nblocks = cluster_ind->size[1] - 1;
  firstBlockLength = 0;
  for (lastBlockLength = 0; lastBlockLength <= nblocks; lastBlockLength++) {
    if (cluster_ind_data[lastBlockLength] != -1.0) {
      firstBlockLength++;
    }
  }
  emxInit_int32_T(&r, 2);
  i = r->size[0] * r->size[1];
  r->size[0] = 1;
  r->size[1] = firstBlockLength;
  emxEnsureCapacity_int32_T(r, i);
  r1 = r->data;
  firstBlockLength = 0;
  for (lastBlockLength = 0; lastBlockLength <= nblocks; lastBlockLength++) {
    if (cluster_ind_data[lastBlockLength] != -1.0) {
      r1[firstBlockLength] = lastBlockLength + 1;
      firstBlockLength++;
    }
  }
  emxInit_real_T(&b_cluster_ind, 2);
  i = b_cluster_ind->size[0] * b_cluster_ind->size[1];
  b_cluster_ind->size[0] = 1;
  b_cluster_ind->size[1] = r->size[1];
  emxEnsureCapacity_real_T(b_cluster_ind, i);
  cluster_data_data = b_cluster_ind->data;
  firstBlockLength = r->size[1];
  for (i = 0; i < firstBlockLength; i++) {
    cluster_data_data[i] = cluster_ind_data[r1[i] - 1];
  }
  emxFree_int32_T(&r);
  emxInit_real_T(&cluster_ids, 2);
  unique_vector(b_cluster_ind, cluster_ids);
  cluster_ids_data = cluster_ids->data;
  if (cluster_ids->size[1] < 2) {
    dunn_index = 0.0;
  } else {
    emxInit_real_T(&cluster_centroids, 2);
    emxInit_real_T(&cluster_intradist, 1);
    i = cluster_centroids->size[0] * cluster_centroids->size[1];
    cluster_centroids->size[0] = cluster_ids->size[1];
    cluster_centroids->size[1] = dataset->size[1];
    emxEnsureCapacity_real_T(cluster_centroids, i);
    cluster_centroids_data = cluster_centroids->data;
    i = cluster_intradist->size[0];
    cluster_intradist->size[0] = cluster_ids->size[1];
    emxEnsureCapacity_real_T(cluster_intradist, i);
    cluster_intradist_data = cluster_intradist->data;
    /*     %% 0) Seperate clusters into cluster_data */
    i = cluster_ids->size[1];
    emxInit_real_T(&cluster_data, 2);
    emxInit_boolean_T(&r2);
    emxInit_int32_T(&r3, 2);
    emxInit_real_T(&x, 1);
    for (id_ind = 0; id_ind < i; id_ind++) {
      i1 = r2->size[0] * r2->size[1];
      r2->size[0] = 1;
      r2->size[1] = cluster_ind->size[1];
      emxEnsureCapacity_boolean_T(r2, i1);
      r4 = r2->data;
      bsum = cluster_ids_data[id_ind];
      firstBlockLength = cluster_ind->size[1];
      for (i1 = 0; i1 < firstBlockLength; i1++) {
        r4[i1] = (cluster_ind_data[i1] == bsum);
      }
      nblocks = r2->size[1] - 1;
      firstBlockLength = 0;
      for (lastBlockLength = 0; lastBlockLength <= nblocks; lastBlockLength++) {
        if (r4[lastBlockLength]) {
          firstBlockLength++;
        }
      }
      i1 = r3->size[0] * r3->size[1];
      r3->size[0] = 1;
      r3->size[1] = firstBlockLength;
      emxEnsureCapacity_int32_T(r3, i1);
      r1 = r3->data;
      firstBlockLength = 0;
      for (lastBlockLength = 0; lastBlockLength <= nblocks; lastBlockLength++) {
        if (r4[lastBlockLength]) {
          r1[firstBlockLength] = lastBlockLength + 1;
          firstBlockLength++;
        }
      }
      firstBlockLength = dataset->size[1];
      i1 = cluster_data->size[0] * cluster_data->size[1];
      cluster_data->size[0] = r3->size[1];
      cluster_data->size[1] = dataset->size[1];
      emxEnsureCapacity_real_T(cluster_data, i1);
      cluster_data_data = cluster_data->data;
      for (i1 = 0; i1 < firstBlockLength; i1++) {
        nblocks = r3->size[1];
        for (i2 = 0; i2 < nblocks; i2++) {
          cluster_data_data[i2 + cluster_data->size[0] * i1] =
              dataset_data[(r1[i2] + dataset->size[0] * i1) - 1];
        }
      }
      if ((r3->size[1] == 0) || (dataset->size[1] == 0)) {
        i1 = b_cluster_ind->size[0] * b_cluster_ind->size[1];
        b_cluster_ind->size[0] = 1;
        b_cluster_ind->size[1] = dataset->size[1];
        emxEnsureCapacity_real_T(b_cluster_ind, i1);
        cluster_data_data = b_cluster_ind->data;
        firstBlockLength = dataset->size[1];
        for (i1 = 0; i1 < firstBlockLength; i1++) {
          cluster_data_data[i1] = 0.0;
        }
      } else {
        i1 = dataset->size[1] - 1;
        i2 = b_cluster_ind->size[0] * b_cluster_ind->size[1];
        b_cluster_ind->size[0] = 1;
        b_cluster_ind->size[1] = dataset->size[1];
        emxEnsureCapacity_real_T(b_cluster_ind, i2);
        cluster_data_data = b_cluster_ind->data;
        if (r3->size[1] <= 1024) {
          firstBlockLength = r3->size[1];
          lastBlockLength = 0;
          nblocks = 1;
        } else {
          firstBlockLength = 1024;
          nblocks = r3->size[1] / 1024;
          lastBlockLength = r3->size[1] - (nblocks << 10);
          if (lastBlockLength > 0) {
            nblocks++;
          } else {
            lastBlockLength = 1024;
          }
        }
        for (xi = 0; xi <= i1; xi++) {
          xpageoffset = xi * r3->size[1];
          cluster_data_data[xi] =
              dataset_data[(r1[xpageoffset % r3->size[1]] +
                            dataset->size[0] * (xpageoffset / r3->size[1])) -
                           1];
          for (k = 2; k <= firstBlockLength; k++) {
            i2 = (xpageoffset + k) - 1;
            cluster_data_data[xi] +=
                dataset_data[(r1[i2 % r3->size[1]] +
                              dataset->size[0] * (i2 / r3->size[1])) -
                             1];
          }
          for (ib = 2; ib <= nblocks; ib++) {
            xblockoffset = xpageoffset + ((ib - 1) << 10);
            bsum =
                dataset_data[(r1[xblockoffset % r3->size[1]] +
                              dataset->size[0] * (xblockoffset / r3->size[1])) -
                             1];
            if (ib == nblocks) {
              hi = lastBlockLength;
            } else {
              hi = 1024;
            }
            for (k = 2; k <= hi; k++) {
              i2 = (xblockoffset + k) - 1;
              bsum += dataset_data[(r1[i2 % r3->size[1]] +
                                    dataset->size[0] * (i2 / r3->size[1])) -
                                   1];
            }
            cluster_data_data[xi] += bsum;
          }
        }
      }
      firstBlockLength = b_cluster_ind->size[1];
      for (i1 = 0; i1 < firstBlockLength; i1++) {
        cluster_centroids_data[id_ind + cluster_centroids->size[0] * i1] =
            cluster_data_data[i1] / (double)r3->size[1];
      }
      firstBlockLength = cluster_centroids->size[1];
      i1 = b_cluster_ind->size[0] * b_cluster_ind->size[1];
      b_cluster_ind->size[0] = 1;
      b_cluster_ind->size[1] = cluster_centroids->size[1];
      emxEnsureCapacity_real_T(b_cluster_ind, i1);
      cluster_data_data = b_cluster_ind->data;
      for (i1 = 0; i1 < firstBlockLength; i1++) {
        cluster_data_data[i1] =
            cluster_centroids_data[id_ind + cluster_centroids->size[0] * i1];
      }
      pdist2(cluster_data, b_cluster_ind, x);
      cluster_data_data = x->data;
      if (x->size[0] == 0) {
        y = 0.0;
      } else {
        if (x->size[0] <= 1024) {
          firstBlockLength = x->size[0];
          lastBlockLength = 0;
          nblocks = 1;
        } else {
          firstBlockLength = 1024;
          nblocks = x->size[0] / 1024;
          lastBlockLength = x->size[0] - (nblocks << 10);
          if (lastBlockLength > 0) {
            nblocks++;
          } else {
            lastBlockLength = 1024;
          }
        }
        y = cluster_data_data[0];
        for (k = 2; k <= firstBlockLength; k++) {
          y += cluster_data_data[k - 1];
        }
        for (ib = 2; ib <= nblocks; ib++) {
          xblockoffset = (ib - 1) << 10;
          bsum = cluster_data_data[xblockoffset];
          if (ib == nblocks) {
            hi = lastBlockLength;
          } else {
            hi = 1024;
          }
          for (k = 2; k <= hi; k++) {
            bsum += cluster_data_data[(xblockoffset + k) - 1];
          }
          y += bsum;
        }
      }
      cluster_intradist_data[id_ind] = y / (double)x->size[0];
    }
    emxFree_real_T(&x);
    emxFree_int32_T(&r3);
    emxFree_boolean_T(&r2);
    emxFree_real_T(&cluster_data);
    /*     %% Plots single cluster centroid to check */
    /*      figure */
    /*      hold on */
    /*      scatter(dataset(:,3),dataset(:,2),4,'blue','filled','diamond') */
    /*      plot(cluster_means{2}(3),cluster_means{2}(2),'rx','LineWidth',4,'MarkerSize',10)
     */
    /*      grid on  */
    /*     %% 3) Compute the interset distances between clusters, and find the
     * minimum of these distances */
    /*     %% Dij - i and j are cluster indices */
    pdist(cluster_centroids, cluster_ids);
    cluster_ids_data = cluster_ids->data;
    /*  Locate which distance pair is it */
    /*      cluster_interdist = squareform(cluster_interdist); */
    /*     %% Check cluster distances */
    /*      dist_12 = sqrt(sum((cluster_means{1}-cluster_means{2}).^2)); */
    /*      if dist_12 == Z(1,2) */
    /*          disp('Correct calculaton'); */
    /*      end */
    nblocks = cluster_intradist->size[0];
    emxFree_real_T(&cluster_centroids);
    if (cluster_intradist->size[0] <= 2) {
      if ((cluster_intradist_data[0] < cluster_intradist_data[1]) ||
          (rtIsNaN(cluster_intradist_data[0]) &&
           (!rtIsNaN(cluster_intradist_data[1])))) {
        bsum = cluster_intradist_data[1];
      } else {
        bsum = cluster_intradist_data[0];
      }
    } else {
      if (!rtIsNaN(cluster_intradist_data[0])) {
        firstBlockLength = 1;
      } else {
        firstBlockLength = 0;
        k = 2;
        exitg1 = false;
        while ((!exitg1) && (k <= nblocks)) {
          if (!rtIsNaN(cluster_intradist_data[k - 1])) {
            firstBlockLength = k;
            exitg1 = true;
          } else {
            k++;
          }
        }
      }
      if (firstBlockLength == 0) {
        bsum = cluster_intradist_data[0];
      } else {
        bsum = cluster_intradist_data[firstBlockLength - 1];
        i = firstBlockLength + 1;
        for (k = i; k <= nblocks; k++) {
          y = cluster_intradist_data[k - 1];
          if (bsum < y) {
            bsum = y;
          }
        }
      }
    }
    emxFree_real_T(&cluster_intradist);
    nblocks = cluster_ids->size[1];
    if (cluster_ids->size[1] <= 2) {
      if (cluster_ids->size[1] == 1) {
        ex = cluster_ids_data[0];
      } else if ((cluster_ids_data[0] >
                  cluster_ids_data[cluster_ids->size[1] - 1]) ||
                 (rtIsNaN(cluster_ids_data[0]) &&
                  (!rtIsNaN(cluster_ids_data[cluster_ids->size[1] - 1])))) {
        ex = cluster_ids_data[cluster_ids->size[1] - 1];
      } else {
        ex = cluster_ids_data[0];
      }
    } else {
      if (!rtIsNaN(cluster_ids_data[0])) {
        firstBlockLength = 1;
      } else {
        firstBlockLength = 0;
        k = 2;
        exitg1 = false;
        while ((!exitg1) && (k <= nblocks)) {
          if (!rtIsNaN(cluster_ids_data[k - 1])) {
            firstBlockLength = k;
            exitg1 = true;
          } else {
            k++;
          }
        }
      }
      if (firstBlockLength == 0) {
        ex = cluster_ids_data[0];
      } else {
        ex = cluster_ids_data[firstBlockLength - 1];
        i = firstBlockLength + 1;
        for (k = i; k <= nblocks; k++) {
          y = cluster_ids_data[k - 1];
          if (ex > y) {
            ex = y;
          }
        }
      }
    }
    dunn_index = bsum / ex;
    /*      dunn_index = dunn_index * abs(all_len-outliers_len)/all_len; */
  }
  emxFree_real_T(&b_cluster_ind);
  emxFree_real_T(&cluster_ids);
  return dunn_index;
}

/*
 * File trailer for Calc_Dunn_Index.c
 *
 * [EOF]
 */
