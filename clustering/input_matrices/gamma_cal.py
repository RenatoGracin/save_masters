
import scipy.io
from scipy.stats import norm
import numpy as np

euclidean_distance = lambda data, point: np.sqrt(np.sum(np.power(data - point, 2), axis = 1).reshape((len(data), 1)))

def gamma(data):
    ''' Calculates the Hubert's Gamma Statistic for the proximity matrix P and matrix Y, where Y (i,j) = 1 
        if i, j are in the same cluster, 0 otherwise. These matrices are fixed for the internal criteria case
        so they are integrated into this function, rather than been provided as arguments.
    
    Parameters:
        data((N x m) 2-d numpy array): a data set of N instances and m features
    
    Returns:
        g(float): the gamma index for P, Y
        
    Reference: Pattern Recognition, S. Theodoridis, K. Koutroumbas
    
    '''
    N = len(data)
    m = len(data[0]) - 1
    
    # Construct the proximity matrix P. This always takes a lot of time.
    P = np.empty((N, N)) 
    for i, point in enumerate(data):
        P[:, [i]] =  euclidean_distance(data[:, :m],point[:m])
    
    # Construct the matrix Y
    Y = np.zeros((N, N))
    for i, _ in enumerate(data):
        same_cluster_indices = np.where(data[:, m] == data[i, m])[0]
        Y[i, same_cluster_indices] = 1
    
    # Calculate the Hubert's Gamma Statistic    
    M = N * (N - 1) / 2
    total_sum = 0.
    for i in range(N):
        total_sum += np.sum(P[i, i + 1:] * Y[i, i + 1:])
    g =  total_sum / M
    
    return g

def main():
    print("Hello World!")
    matrix_data = scipy.io.loadmat('big_dataset_feature_selection.mat')
    dataset = matrix_data['feature_matrix']
    g = gamma(dataset)
    print("Gamma calculated: " + str(g))

if __name__ == "__main__":
    main()

