from sklearn import datasets
import matplotlib.pyplot as plt
import seaborn as sns

n_samples=150
noisy_moons = datasets.make_moons(n_samples=n_samples, noise=.05)
X = noisy_moons[0]
plt.scatter(X[:,0], X[:,1])
plt.show()

from sklearn.cluster import KMeans

kmeans =  KMeans(n_clusters=2)
kmeans_labels = kmeans.fit_predict(X)
plt.scatter(X[:,0], X[:,1], c=kmeans_labels)
plt.show()

import hdbscan

hdbscanner = hdbscan.HDBSCAN()
hdbscan_labels = hdbscanner.fit_predict(X)
plt.scatter(X[:,0], X[:,1], c=hdbscan_labels)

from scipy.spatial.distance import euclidean

kmeans_score = DBCV(X, kmeans_labels, dist_function=euclidean)
hdbscan_score = DBCV(X, hdbscan_labels, dist_function=euclidean)
print(kmeans_score, hdbscan_score)