from tkinter.tix import MAIN
from pip import main
import DBCV
from sklearn import datasets
import pytest
from sklearn.cluster import KMeans
import hdbscan
from scipy.spatial.distance import euclidean
import numpy as np
from scipy.io import *
import scipy.io
from hdbscan import tests

@pytest.fixture
def data():
    n_samples = 60
    noisy_moons = datasets.make_moons(n_samples=n_samples, noise=.05,
                                      random_state=1)
    X = noisy_moons[0]
    return X


def test_DBCV(data):
    kmeans = KMeans(n_clusters=2)
    kmeans_labels = kmeans.fit_predict(data)
    hdbscanner = hdbscan.HDBSCAN()
    hdbscan_labels = hdbscanner.fit_predict(data)
    kmeans_score = DBCV.DBCV(data, kmeans_labels, dist_function=euclidean)
    hdbscan_score = DBCV.DBCV(data, hdbscan_labels, dist_function=euclidean)
    assert hdbscan_score > kmeans_score


def test__core_dist(data):
    target = 0.09325490419185979
    point = data[0]
    core_dist = DBCV._core_dist(point, data, euclidean)
    assert abs(core_dist - target) < 0.001


def test__mutual_reachability_dist(data):
    target = 0.074196034579080888
    point_1 = data[0]
    point_2 = data[1]
    dist = DBCV._mutual_reachability_dist(point_1, point_2, data, data,
                                          euclidean)
    assert dist == euclidean(point_1, point_2)
    point_3 = data[5]
    point_4 = data[46]
    dist_2 = DBCV._mutual_reachability_dist(point_3, point_4, data, data,
                                            euclidean)
    assert abs(dist_2 - target) < 0.001


def test__mutual_reach_dist_graph(data):
    target = 0.09872567819414102
    hdbscanner = hdbscan.HDBSCAN()
    hdbscan_labels = hdbscanner.fit_predict(data)
    graph = DBCV._mutual_reach_dist_graph(data, hdbscan_labels,
                                          euclidean)
    assert graph.shape == (data.shape[0], data.shape[0])
    assert abs(graph[0][0] - target < 0.001)


def test__mutual_reach_dist_MST():
    test_array = np.array([[0, 1, 0, 0, 0, 0],
                           [0, 0, 1, 0, 0, 0],
                           [0, 0, 0, 2, 0, 0],
                           [0, 0, 0, 0, 1, 0],
                           [0, 0, 0, 0, 0, 1],
                           [0, 0, 0, 0, 0, 0]])
    target_array = np.array([[0, 1, 0, 0, 0, 0],
                             [1, 0, 1, 0, 0, 0],
                             [0, 1, 0, 2, 0, 0],
                             [0, 0, 2, 0, 1, 0],
                             [0, 0, 0, 1, 0, 1],
                             [0, 0, 0, 0, 1, 0]])
    mst = DBCV._mutual_reach_dist_MST(test_array)
    assert np.array_equal(mst, target_array)


def test__cluster_density_sparseness():
    test_array = np.array([[0, 1, 0, 0, 0, 0],
                           [1, 0, 1, 0, 0, 0],
                           [0, 1, 0, 2, 0, 0],
                           [0, 0, 2, 0, 1, 0],
                           [0, 0, 0, 1, 0, 1],
                           [0, 0, 0, 0, 1, 0]])
    labels = np.array([0, 0, 0, 1, 1, 1])
    cluster = 1
    density = DBCV._cluster_density_sparseness(test_array,
                                               labels, cluster)
    assert density == 1


def test__cluster_density_separation():
    test_array = np.array([[0, 1, 0, 0, 0, 0],
                           [1, 0, 1, 0, 0, 0],
                           [0, 1, 0, 2, 0, 0],
                           [0, 0, 2, 0, 1, 0],
                           [0, 0, 0, 1, 0, 1],
                           [0, 0, 0, 0, 1, 0]])
    labels = np.array([0, 0, 0, 1, 1, 1])
    separation = DBCV._cluster_density_separation(test_array,
                                                  labels, 0, 1)
    assert separation == 2


def test__cluster_validity_index():
    test_array = np.array([[0, 1, 0, 0, 0, 0],
                           [1, 0, 1, 0, 0, 0],
                           [0, 1, 0, 2, 0, 0],
                           [0, 0, 2, 0, 1, 0],
                           [0, 0, 0, 1, 0, 1],
                           [0, 0, 0, 0, 1, 0]])
    labels = np.array([0, 0, 0, 1, 1, 1])
    validity = DBCV._cluster_validity_index(test_array,
                                            labels, 0)
    assert validity == 0.5


def test__clustering_validity_index():
    test_array = np.array([[0, 1, 0, 0, 0, 0],
                           [1, 0, 1, 0, 0, 0],
                           [0, 1, 0, 2, 0, 0],
                           [0, 0, 2, 0, 1, 0],
                           [0, 0, 0, 1, 0, 1],
                           [0, 0, 0, 0, 1, 0]])
    labels = np.array([0, 0, 0, 1, 1, 1])
    validity = DBCV._clustering_validity_index(test_array,
                                               labels)
    assert validity == 0.5


def test__get_label_members():
    test_array = np.array([[0, 1, 0, 0, 0, 0],
                           [1, 0, 1, 0, 0, 0],
                           [0, 1, 0, 2, 0, 0],
                           [0, 0, 2, 0, 1, 0],
                           [0, 0, 0, 1, 0, 1],
                           [0, 0, 0, 0, 1, 0]])
    labels = np.array([0, 0, 0, 1, 1, 1])
    members = DBCV._get_label_members(test_array, labels, 0)
    target = test_array[np.array([0, 1, 2])]
    assert np.array_equal(target, members)


def main():
    matrix_data = scipy.io.loadmat("C:\\Users\\bujak\\Desktop\\FER\\5. godina\\DIPLOMSKI PROJEKT\\DILPOMSKI RAD\\plant_AE_classification\\clustering\\DBCV_index\\DBCV\\DBCV\\DBCV_input.mat") 
    all_labels = matrix_data['labels'][0]
    MSTs = matrix_data['MST'][0]
    epsilons = matrix_data['epsilon_comb'][0]

    for i in range(0,len(MSTs)):
        labels = all_labels[i]
        MST = MSTs[i]
        mst = DBCV._mutual_reach_dist_MST(MST)

        cluster_validity = DBCV._clustering_validity_index(mst, labels)
        print("cluster_validity for epsilon= "+str(epsilons[i])+" : " + str(cluster_validity))

    print('Done!')

    # my_score = DBCV.DBCV(data, labels, dist_function=euclidean)
    # matrix_weights = scipy.io.loadmat("C:\\Users\\bujak\\Desktop\\FER\\5. godina\\DIPLOMSKI PROJEKT\\DILPOMSKI RAD\\plant_AE_classification\\clustering\\DBCV_index\\DBCV\\DBCV\\DBCV_weights.mat")
    # graph = matrix_weights['weights']
    

if __name__ == "__main__":
    main()
