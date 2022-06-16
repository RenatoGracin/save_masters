import itertools
from re import sub
from sklearn.datasets import make_blobs
from sklearn.cluster import OPTICS
from sklearn.metrics.cluster import silhouette_score
from sklearn.metrics.cluster import davies_bouldin_score
from sklearn.metrics.cluster import calinski_harabasz_score
import numpy as np
import matplotlib.pyplot as plt
import scipy.io
from random import seed
from random import randint
from itertools import combinations




# Configuration options
num_samples_total = 1000
cluster_centers = [(3,3), (7,7)]
num_classes = len(cluster_centers)
epsilon = 3
min_samples = 3
cluster_method = 'xi'
metric = 'euclidean'#'mahalanobis'

# Generate data
X, y = make_blobs(n_samples = num_samples_total, centers = cluster_centers, n_features = num_classes, center_box=(0, 1), cluster_std = 0.5)

matrix_data = scipy.io.loadmat('c:/Users/bujak/Desktop/FER/5. godina/DIPLOMSKI PROJEKT/DILPOMSKI RAD/plant_AE_classification/clustering/input_matrices/small_dataset_stand_feature_matrix.mat')
X = matrix_data['dataset']
features = np.subtract([13,18,19],[1,1,1])
X = X[:,features]

# fig = plt.figure()
# ax = fig.add_subplot(projection='3d')

# ax.scatter(X[:,0], X[:,1], X[:,2], s=4, marker="o", picker=True)
# plt.show()

# Compute OPTICS
# db = OPTICS(max_eps=epsilon, min_samples=min_samples, cluster_method=cluster_method, metric=metric, metric_params={'VI': scipy.linalg.inv(np.cov(X, rowvar=False))}).fit(X)
db = OPTICS(max_eps=epsilon, min_samples=min_samples, cluster_method=cluster_method, metric=metric).fit(X)
labels = db.labels_

no_clusters = len(np.unique(labels) )
no_noise = np.sum(np.array(labels) == -1, axis=0)

print('Estimated no. of clusters: %d' % no_clusters)
print('Estimated no. of noise points: %d' % no_noise)
## See FS results
colors = list()
for x in labels:
  if x==-1:
    # x=len(np.unique(labels))+1
    colors.append("#000000")
    continue
  # color = str(hex(randint(0,2^5-1)))[2::]
  color = str(hex(0x00e5f7*x))[2::]
  color = "#" + "0"*(6-len(color)) + color
  colors.append(color)
fig = plt.figure()
ax = fig.add_subplot(projection='3d')

ax.scatter(X[:,0], X[:,1], X[:,2], s=4, c=colors, marker="o", picker=True)
plt.title(f'OPTICS clustering')
plt.xlabel('Axis X[0]')
plt.ylabel('Axis X[1]')
plt.show()

features = [1,2,3,5,11,21]
features.extend(list(range(13,19+1)))
num_of_feat = len(features)
features = np.subtract(features,np.ones([1,num_of_feat],dtype=int))[0]
min_num_feat = 3
max_num_feat = 5

subsets  = list()
for L in range(0, num_of_feat+1):
    for subset in itertools.combinations(features, L):
        if len(subset) >= min_num_feat and len(subset)<=max_num_feat:
          subsets.append(subset)

print("Number of subsets: " + str(len(subsets)))

silh_scores = list()
db_scores = list()
ch_scores = list()

for sub_ind,subset in enumerate(subsets):
    subset_data = X[:,subset]
    db = OPTICS(max_eps=epsilon, min_samples=min_samples, cluster_method=cluster_method, metric=metric).fit(subset_data)
    labels = db.labels_

    silh_scores.append(silhouette_score(subset_data,labels))
    db_scores.append(davies_bouldin_score(subset_data,labels))
    ch_scores.append(calinski_harabasz_score(subset_data,labels))
    print("Done with subset: " + str(sub_ind)+"/"+str(len(subsets)))

print(max(silh_scores))
print(min(db_scores))
print(max(ch_scores))

feat_names = ["rise time","counts to","counts from","duration","peak amplitude","average frequency",
              "rms","asl","reverbation frequency","initial frequency","signal strength","absolute energy",
              "pp1","pp2","pp3","pp4","centroid frequency","peak frequency","amplitude of peak frequency","num of freq peaks",
              "weighted peak frequency"]

print("silh feats: " + str(np.array(feat_names)[np.asarray(subsets[np.argmax(silh_scores)])]))
print("db feats: " + str(np.array(feat_names)[np.asarray(subsets[np.argmin(db_scores)])]))
print("ch feats: " + str(np.array(feat_names)[np.asarray(subsets[np.argmax(ch_scores)])]))

# Voting scheme calculation
db_sorted_ind = np.argsort(db_scores)
ch_sorted_ind = np.argsort(ch_scores)[::-1]
silh_sorted_ind = np.argsort(silh_scores)[::-1]

voting_scheme = [0] * len(subsets)
for ele_ind in range(25-1,-1,-1):
    voting_scheme[db_sorted_ind[ele_ind]] +=ele_ind+1
    voting_scheme[ch_sorted_ind[ele_ind]] +=ele_ind+1
    voting_scheme[silh_sorted_ind[ele_ind]] +=ele_ind+1

best_features_ind = np.argsort(voting_scheme)[::-1]
print("Voting scheme 1st features: " + str(subsets[best_features_ind[0]]))
print("Voting scheme 2nd features: " + str(subsets[best_features_ind[1]]))
print("Voting scheme 3rd features: " + str(subsets[best_features_ind[2]]))
print("Voting scheme 4th features: " + str(subsets[best_features_ind[3]]))
print("Voting scheme 5th features: " + str(subsets[best_features_ind[4]]))


db = OPTICS(max_eps=epsilon, min_samples=min_samples, cluster_method=cluster_method, metric=metric).fit(X)
labels = db.labels_

plt.bar(db.ordering_,db.reachability_)
# plt.show()

clust_num = 0
for rech_dist in db.reachability_:
  if rech_dist > epsilon:
    clust_num+=1


no_clusters = len(np.unique(labels) )
no_noise = np.sum(np.array(labels) == -1, axis=0)

print('Estimated no. of clusters: %d' % no_clusters)
print('Estimated no. of noise points: %d' % no_noise)

# Generate scatter plot for training data
scipy.io.savemat('optics_result.mat', {'result_idx': labels, 'reach_dist_py':db.reachability_, 'order_py':db.ordering_})
colors = list()
for x in labels:
  if x==-1:
    # x=len(np.unique(labels))+1
    colors.append("#000000")
    continue
  # color = str(hex(randint(0,2^5-1)))[2::]
  color = str(hex(0x00e5f7*x))[2::]
  color = "#" + "0"*(6-len(color)) + color
  colors.append(color)
fig = plt.figure()
ax = fig.add_subplot(projection='3d')

ax.scatter(X[:,0], X[:,1], X[:,2], s=4, c=colors, marker="o", picker=True)
plt.title(f'OPTICS clustering')
plt.xlabel('Axis X[0]')
plt.ylabel('Axis X[1]')
plt.show()
