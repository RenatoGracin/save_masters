from re import T
import scipy.io
from matplotlib import pyplot as plt
from mpl_toolkits import mplot3d
import numpy as np
import hdbscan
from sklearn.cluster import OPTICS

# Test efficacy of HDBSCAN
matrix_data = scipy.io.loadmat("C:\\Users\\bujak\\Desktop\\FER\\5_godina\\DIPLOMSKI_PROJEKT\\DILPOMSKI_RAD\\plant_AE_classification\\clustering\\input_matrices\\small_dataset_stand_feature_matrix.mat") 
data = matrix_data['dataset']
# data = data[:,[11-1,18-1,19-1]]
# data = data[:,[6-1,10-1,17-1]]
# data = data[:,[8-1,11-1,19-1]]
data = data[:,[1-1,12-1,18-1]]

colors = np.array(["red","green","blue","yellow","pink","black","orange","purple","beige","brown","gray","cyan","magenta"])
figures_path = "C:\\Users\\bujak\\Desktop\\FER\\5_godina\\DIPLOMSKI_PROJEKT\\DILPOMSKI_RAD\\plant_AE_classification\\figures\\clustering\\test_hdbscan\\"

clusterer = hdbscan.HDBSCAN(algorithm='best', alpha=1.0, allow_single_cluster=True, metric='euclidean', min_cluster_size=40, min_samples=3)#, cluster_selection_epsilon=0.08)

clusterer.fit(data)

eps = clusterer.cluster_selection_epsilon
best_labels = clusterer.labels_

# Use OPTICS
clustering = OPTICS(min_samples=5,metric='euclidean',max_eps=np.inf,cluster_method='xi').fit(data)
ordered_reach = clustering.reachability_[clustering.ordering_]
best_labels = clustering.labels_
order = clustering.ordering_

ordered_labels = best_labels[clustering.ordering_]
x_axis = np.array(list(range(0,len(data[:,0]))))
fig = plt.figure()
uni_labels = np.unique(ordered_labels)
print("Number od clusters: "+str(len(uni_labels)))
for label_ind,label in enumerate(uni_labels):
    color_name = colors[label_ind%12+1]
    if label==-1:
        color = colors[0]
    plt.scatter(x_axis[label==ordered_labels],ordered_reach[label==ordered_labels],s=5,c = color_name)
plt.show()

fig = plt.figure()
ax = plt.axes(projection ="3d")

my_labels = np.ones(len(data[:,0]),dtype=int)*-1
my_labels[79:620] = 1
my_labels[630:720] = 2
best_labels = my_labels
uni_labels = np.unique(best_labels)
print("Number od clusters: "+str(len(uni_labels)))
for label_ind,label in enumerate(uni_labels):
    color = colors[label_ind%12+1]
    if label==-1:
        color = colors[0]
    ax.scatter3D(data[label==best_labels,0],data[label==best_labels,1],data[label==best_labels,2],s=5,c=color)
plt.show()
fig.savefig(figures_path + 'hdbscan_cluster')
print('Done hdbscan clustering!')

# import pandas as pd
# pd.set_option('display.max_columns', None)
# df = pd.DataFrame(matrix_data['equ_feature_matrix'],columns=['rise time','counts to','counts from','duration',
#         'peak amplitude','average frequency','rms','asl','reverbation frequency',
#         'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',
#         'pp3','pp4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks','weighted peak frequency'])
# print(df['rise time'].head())
# df.hist(column='pp2',bins=100)
# df.hist(column='pp3',bins=100)
# df.plot(kind = 'scatter', x = 'pp2', y = 'pp3')
# plt.show()
#print(df.describe())

#print(matrix_data['equ_feature_matrix'][0])

from cmath import inf
from operator import index
from sklearn import feature_selection
from sklearn.cluster import OPTICS
from sklearn.metrics.cluster import silhouette_score
from sklearn.metrics.cluster import davies_bouldin_score
from sklearn.metrics.cluster import calinski_harabasz_score
from ClustersFeatures import *
from enum import unique
from hdbscan import validity_index
from s_dbw import S_Dbw
from s_dbw import SD
from cdbw import CDbw
#from hdbscan.tests import test_hdbscan
from numpy import argmax, dtype, int32, unicode_
import scipy.io
from matplotlib import pyplot as pyp
from sklearn.datasets import make_blobs
from sklearn.utils import shuffle
from sklearn.metrics import adjusted_rand_score
from sklearn.preprocessing import StandardScaler
from hdbscan import HDBSCAN
import numpy as np
import pandas as pd
from tabulate import *

figures_path = "C:\\Users\\bujak\\Desktop\\FER\\5_godina\\DIPLOMSKI_PROJEKT\\DILPOMSKI_RAD\\plant_AE_classification\\figures\\clustering\\test_validity_indices_py\\"

matrix_data = scipy.io.loadmat("C:\\Users\\bujak\\Desktop\\FER\\5_godina\\DIPLOMSKI_PROJEKT\\DILPOMSKI_RAD\\plant_AE_classification\\clustering\\saved_idx.mat") 
goal_data = scipy.io.loadmat("C:\\Users\\bujak\\Desktop\\FER\\5_godina\\DIPLOMSKI_PROJEKT\\DILPOMSKI_RAD\\plant_AE_classification\\clustering\\goal_density_clust.mat") 
datasets = matrix_data['density_based_datasets'][0]
all_labels = matrix_data['idxes']
all_epsilons = goal_data['goal_idxes']

colors = np.array(["red","green","blue","yellow","pink","black","orange","purple","beige","brown","gray","cyan","magenta"])
headers = list()
headers.append('Index')
best_table_data = list()

best_DBCV_indices = list()
best_DBCV_indices.append("DBCV")
best_S_Dbw_indices = list()
best_S_Dbw_indices.append("S_Dbw")
best_SD_indices = list()
best_SD_indices.append("SD")
best_CDbw_indices = list()
best_CDbw_indices.append("CDbw")
best_DB_indices = list()
best_DB_indices.append("DB")
best_Silh_indices = list()
best_Silh_indices.append("Silh")
best_CH_indices = list()
best_CH_indices.append("CH")

best_DBCV_indices_with_out = list()
best_DBCV_indices_with_out.append("DBCV_with_out")
best_S_Dbw_indices_with_out = list()
best_S_Dbw_indices_with_out.append("S_Dbw_with_out")
best_SD_indices_with_out = list()
best_SD_indices_with_out.append("SD_with_out")
best_CDbw_indices_with_out = list()
best_CDbw_indices_with_out.append("CDbw_with_out")
best_DB_indices_with_out = list()
best_DB_indices_with_out.append("DB_with_out")
best_Silh_indices_with_out = list()
best_Silh_indices_with_out.append("Silh_with_out")
best_CH_indices_with_out = list()
best_CH_indices_with_out.append("CH_with_out")

pearsons_coefficient_table_data = list()

pearsons_coefficient_DBCV = list()
pearsons_coefficient_DBCV.append("DBCV")
pearsons_coefficient_CDbw = list()
pearsons_coefficient_CDbw.append("CDbw")
pearsons_coefficient_S_Dbw = list()
pearsons_coefficient_S_Dbw.append("S_Dbw")
pearsons_coefficient_SD = list()
pearsons_coefficient_SD.append("SD")
pearsons_coefficient_Silh = list()
pearsons_coefficient_Silh.append("Silh")
pearsons_coefficient_DB = list()
pearsons_coefficient_DB.append("DB")
pearsons_coefficient_CH = list()
pearsons_coefficient_CH.append("CH")

pearsons_coefficient_DBCV_with_out = list()
pearsons_coefficient_DBCV_with_out.append("DBCV_with_out")
pearsons_coefficient_CDbw_with_out = list()
pearsons_coefficient_CDbw_with_out.append("CDbw_with_out")
pearsons_coefficient_S_Dbw_with_out = list()
pearsons_coefficient_S_Dbw_with_out.append("S_Dbw_with_out")
pearsons_coefficient_SD_with_out = list()
pearsons_coefficient_SD_with_out.append("SD_with_out")
pearsons_coefficient_Silh_with_out = list()
pearsons_coefficient_Silh_with_out.append("Silh_with_out")
pearsons_coefficient_DB_with_out = list()
pearsons_coefficient_DB_with_out.append("DB_with_out")
pearsons_coefficient_CH_with_out = list()
pearsons_coefficient_CH_with_out.append("CH_with_out")


for dataset_ind,dataset in enumerate(datasets):
    headers.append('Dataset'+str(dataset_ind))

    DBCV_index_per_dataset = list()
    S_Dbw_index_per_dataset = list()
    SD_index_per_dataset = list()
    CDbw_index_per_dataset = list()
    ARI_index_per_dataset = list()
    DB_index_per_dataset = list()
    Silh_index_per_dataset = list()
    CH_index_per_dataset = list()
    DBCV_index_per_dataset_with_out = list()
    S_Dbw_index_per_dataset_with_out = list()
    SD_index_per_dataset_with_out = list()
    CDbw_index_per_dataset_with_out = list()
    DB_index_per_dataset_with_out = list()
    Silh_index_per_dataset_with_out = list()
    CH_index_per_dataset_with_out = list()

    data = np.array(dataset,dtype=dtype('float64'))[0]
    goal_labels = all_epsilons[0][dataset_ind]
    goal_labels = np.transpose(goal_labels)[0]

    for eps_ind,epsilon_based_labels in enumerate(all_labels[dataset_ind]):
        # labels = HDBSCAN().fit(X).labels_
        ## End of labels for this dataset
        if not np.any(epsilon_based_labels):
            continue

        labels = np.transpose(epsilon_based_labels)[0]
        #index = validity_index(X,epsilon_based_labels)
        if len(np.unique(labels[labels!=-1])) < 2 or len(np.unique(labels[labels!=-1])) > 10:
            DBCV_index = -1
            S_Dbw_index = inf
            SD_index = inf
            CDbw_index = 0
            ARI_index = -1
            Silh_index = -1
            DB_index = 1
            CH_index = 0
            DBCV_index_with_out = -1
            S_Dbw_index_with_out = inf
            SD_index_with_out = inf
            CDbw_index_with_out = 0
            Silh_index_with_out = -1
            DB_index_with_out = 1
            CH_index_with_out = 0
        else:
            DBCV_index = validity_index(dataset[labels!=-1,:],labels[labels!=-1])
            S_Dbw_index = S_Dbw(dataset[labels!=-1,:],labels[labels!=-1])
            SD_index = SD(dataset[labels!=-1,:],labels[labels!=-1])
            CDbw_index = CDbw(dataset[labels!=-1,:],labels[labels!=-1]-1,s=10)
            DB_index = davies_bouldin_score(dataset[labels!=-1,:],labels[labels!=-1])
            Silh_index = silhouette_score(dataset[labels!=-1,:],labels[labels!=-1])
            CH_index = calinski_harabasz_score(dataset[labels!=-1,:],labels[labels!=-1])
            ARI_index = adjusted_rand_score(goal_labels,labels)

            # pd_df=pd.DataFrame(dataset[labels!=-1,:])
            # pd_df['target'] = labels[labels!=-1]
            # CC=ClustersCharacteristics(pd_df,label_target="target")
            # CC.compute_every_index()
            # Dunn_index = CC['general']['max']['Dunn']


            outliers_len = len(labels[labels==-1])
            data_len = len(labels)
            outliers_factor = (data_len-outliers_len)/data_len
            if DBCV_index > 0: ## from -1 to 1, max is best
                DBCV_index_with_out = DBCV_index * outliers_factor
            else:
                DBCV_index_with_out = DBCV_index / outliers_factor

            S_Dbw_index_with_out = (S_Dbw_index) / outliers_factor ## greater than 0, min is best
            SD_index_with_out = (SD_index) / outliers_factor ## greater than 0, min is best
            CDbw_index_with_out = (CDbw_index) * outliers_factor ## greater than 0, max is best
            if Silh_index > 0: ## from -1 to 1, max is best
                Silh_index_with_out = Silh_index * outliers_factor
            else:
                Silh_index_with_out = Silh_index / outliers_factor
            
            DB_index_with_out = (DB_index) / outliers_factor ## from 0 to 1, min is best
            # CH = The same as variance ration criterion VRC
            CH_index_with_out = (CH_index) * outliers_factor ## from 0 to Inf, max is best

        DBCV_index_per_dataset.append(DBCV_index)
        S_Dbw_index_per_dataset.append(S_Dbw_index)
        SD_index_per_dataset.append(SD_index)
        CDbw_index_per_dataset.append(CDbw_index)
        ARI_index_per_dataset.append(ARI_index)
        Silh_index_per_dataset.append(Silh_index)
        DB_index_per_dataset.append(DB_index)
        CH_index_per_dataset.append(CH_index)
        DBCV_index_per_dataset_with_out.append(DBCV_index_with_out)
        S_Dbw_index_per_dataset_with_out.append(S_Dbw_index_with_out)
        SD_index_per_dataset_with_out.append(SD_index_with_out)
        CDbw_index_per_dataset_with_out.append(CDbw_index_with_out)
        Silh_index_per_dataset_with_out.append(Silh_index_with_out)
        DB_index_per_dataset_with_out.append(DB_index_with_out)
        CH_index_per_dataset_with_out.append(CH_index_with_out)
        print("Done for: " + str(eps_ind) + str('/') + str(len(all_labels[dataset_ind])) )
        if eps_ind == 0:
            fig = pyp.figure()
            pyp.title("Goal clustering for dataset"+str(dataset_ind))
            uni_labels = np.unique(goal_labels)
            for label_ind,label in enumerate(uni_labels):
                color = colors[label_ind%10+1]
                if label==-1:
                    color = colors[0]
                pyp.scatter(dataset[label==goal_labels,0],dataset[label==goal_labels,1],s=5,c=color)
            fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_goal_cluster')

    max_val = max(DBCV_index_per_dataset)
    max_ind = np.argmax(DBCV_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best DBCV_index was ' + str(max_val)
    print(info_str)
    best_DBCV_indices.append(max_val)
    
    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_DBCV_best_cluster')

    min_val = min(S_Dbw_index_per_dataset)
    min_ind = np.argmin(S_Dbw_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][min_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best S_Dbw_index was ' + str(min_val)
    print(info_str)
    best_S_Dbw_indices.append(min_val)
    
    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_S_Dbw_best_cluster')

    min_val = min(SD_index_per_dataset)
    min_ind = np.argmin(SD_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][min_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best SD_index was ' + str(min_val)
    print(info_str)
    best_SD_indices.append(min_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_SD_best_cluster')

    max_val = max(CDbw_index_per_dataset)
    max_ind = np.argmax(CDbw_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best CDbw_index was ' + str(max_val)
    print(info_str)
    best_CDbw_indices.append(max_val)

    fig = pyp.figure()
    pyp.title(info_str)  
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_CDbw_best_cluster')

    max_val = max(Silh_index_per_dataset)
    max_ind = np.argmax(Silh_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best Silh_index was ' + str(max_val)
    print(info_str)
    best_Silh_indices.append(max_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_Silh_best_cluster')

    min_val = min(DB_index_per_dataset)
    min_ind = np.argmin(DB_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][min_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best DB_index was ' + str(min_val)
    print(info_str)
    best_DB_indices.append(min_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_DB_best_cluster')

    max_val = max(CH_index_per_dataset)
    max_ind = np.argmax(CH_index_per_dataset)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best CH_index was ' + str(max_val)
    print(info_str)
    best_CH_indices.append(max_val)
    
    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_CH_best_cluster')

    ## now for with outliers factor
    max_val = max(DBCV_index_per_dataset_with_out)
    max_ind = np.argmax(DBCV_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best DBCV_index_with_out was ' + str(max_val)
    print(info_str)
    best_DBCV_indices_with_out.append(max_val)
    
    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_DBCV_best_cluster_with_out')

    min_val = min(S_Dbw_index_per_dataset_with_out)
    min_ind = np.argmin(S_Dbw_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][min_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best S_Dbw_index_with_out was ' + str(min_val)
    print(info_str)
    best_S_Dbw_indices_with_out.append(min_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_S_Dbw_best_cluster_with_out')

    min_val = min(SD_index_per_dataset_with_out)
    min_ind = np.argmin(SD_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][min_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best SD_index_with_out was ' + str(min_val)
    print(info_str)
    best_SD_indices_with_out.append(min_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_SD_best_cluster_with_out')

    max_val = max(CDbw_index_per_dataset_with_out)
    max_ind = np.argmax(CDbw_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best CDbw_index_with_out was ' + str(max_val)
    print(info_str)
    best_CDbw_indices_with_out.append(max_val)

    fig = pyp.figure()
    pyp.title(info_str)  
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_CDbw_best_cluster_with_out')

    max_val = max(Silh_index_per_dataset_with_out)
    max_ind = np.argmax(Silh_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best Silh_index_with_out was ' + str(max_val)
    print(info_str)
    best_Silh_indices_with_out.append(max_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_Silh_best_cluster_with_out')

    min_val = min(DB_index_per_dataset_with_out)
    min_ind = np.argmin(DB_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][min_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best DB_index_with_out was ' + str(min_val)
    print(info_str)
    best_DB_indices_with_out.append(min_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_DB_best_cluster_with_out')

    max_val = max(CH_index_per_dataset_with_out)
    max_ind = np.argmax(CH_index_per_dataset_with_out)

    best_labels = np.transpose(all_labels[dataset_ind][max_ind])[0]
    info_str = 'For dataset' + str(dataset_ind) + ' best CH_index_with_out was ' + str(max_val)
    print(info_str)
    best_CH_indices_with_out.append(max_val)

    fig = pyp.figure()
    pyp.title(info_str)
    uni_labels = np.unique(best_labels)
    for label_ind,label in enumerate(uni_labels):
        color = colors[label_ind%10+1]
        if label==-1:
            color = colors[0]
        pyp.scatter(dataset[label==best_labels,0],dataset[label==best_labels,1],s=5,c=color)
    fig.savefig(figures_path + 'dataset' + str(dataset_ind) + '_CH_best_cluster_with_out')

    ## Calculate correlation between ARI and each index
    valid_ARI_indices =np.array(ARI_index_per_dataset)!=-1

    # to return the upper three quartiles
    pearsons_coefficient_DBCV.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(DBCV_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and DBCV_index is: " + str(pearsons_coefficient_DBCV[dataset_ind]))

    pearsons_coefficient_S_Dbw.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(S_Dbw_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and S_Dbw_index is: " + str(pearsons_coefficient_S_Dbw[dataset_ind]))

    pearsons_coefficient_SD.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(SD_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and SD_index is: " + str(pearsons_coefficient_SD[dataset_ind]))

    pearsons_coefficient_CDbw.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(CDbw_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and CDbw_index is: " + str(pearsons_coefficient_CDbw[dataset_ind]))

    pearsons_coefficient_Silh.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(Silh_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and Silh_index is: " + str(pearsons_coefficient_Silh[dataset_ind]))

    pearsons_coefficient_DB.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(DB_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and DB_index is: " + str(pearsons_coefficient_DB[dataset_ind]))

    pearsons_coefficient_CH.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(CH_index_per_dataset)[valid_ARI_indices]))
    print("The pearson's coeffient ARI and CH_index is: " + str(pearsons_coefficient_CH[dataset_ind]))

    # to return the upper three quartiles
    pearsons_coefficient_DBCV_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(DBCV_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and DBCV_index_with_out  is: " + str(pearsons_coefficient_DBCV_with_out[dataset_ind] ))

    pearsons_coefficient_S_Dbw_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(S_Dbw_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and S-Dbw_index_with_out  is: " + str(pearsons_coefficient_S_Dbw_with_out[dataset_ind] ))

    pearsons_coefficient_SD_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(SD_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and SD_index_with_out  is: " + str(pearsons_coefficient_SD_with_out[dataset_ind] ))

    pearsons_coefficient_CDbw_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(CDbw_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and CDbw_index_with_out  is: " + str(pearsons_coefficient_CDbw_with_out[dataset_ind] ))

    pearsons_coefficient_Silh_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(Silh_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and Silh_index_with_out  is: " + str(pearsons_coefficient_Silh_with_out[dataset_ind] ))

    pearsons_coefficient_DB_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(DB_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and DB_index_with_out  is: " + str(pearsons_coefficient_DB_with_out[dataset_ind] ))

    pearsons_coefficient_CH_with_out.append(np.corrcoef(np.array(ARI_index_per_dataset)[valid_ARI_indices], np.array(CH_index_per_dataset_with_out )[valid_ARI_indices]))
    print("The pearson's coeffient ARI and CH_index_with_out  is: " + str(pearsons_coefficient_CH_with_out[dataset_ind] ))

    print("Done for dataset")


best_table_data.append(best_DBCV_indices)
best_table_data.append(best_S_Dbw_indices)
best_table_data.append(best_SD_indices)
best_table_data.append(best_CDbw_indices)
best_table_data.append(best_DB_indices)
best_table_data.append(best_Silh_indices)
best_table_data.append(best_CH_indices)
best_table_data.append(best_DBCV_indices_with_out)
best_table_data.append(best_S_Dbw_indices_with_out)
best_table_data.append(best_SD_indices_with_out)
best_table_data.append(best_CDbw_indices_with_out)
best_table_data.append(best_DB_indices_with_out)
best_table_data.append(best_Silh_indices_with_out)
best_table_data.append(best_CH_indices_with_out)

pearsons_coefficient_table_data.append(pearsons_coefficient_DBCV)
pearsons_coefficient_table_data.append(pearsons_coefficient_S_Dbw)
pearsons_coefficient_table_data.append(pearsons_coefficient_SD)
pearsons_coefficient_table_data.append(pearsons_coefficient_CDbw)
pearsons_coefficient_table_data.append(pearsons_coefficient_Silh)
pearsons_coefficient_table_data.append(pearsons_coefficient_DB)
pearsons_coefficient_table_data.append(pearsons_coefficient_CH)
pearsons_coefficient_table_data.append(pearsons_coefficient_DBCV_with_out)
pearsons_coefficient_table_data.append(pearsons_coefficient_S_Dbw_with_out)
pearsons_coefficient_table_data.append(pearsons_coefficient_SD_with_out)
pearsons_coefficient_table_data.append(pearsons_coefficient_CDbw_with_out)
pearsons_coefficient_table_data.append(pearsons_coefficient_Silh_with_out)
pearsons_coefficient_table_data.append(pearsons_coefficient_DB_with_out)
pearsons_coefficient_table_data.append(pearsons_coefficient_CH_with_out)

with open('figures/clustering/test_validity_indices_matlab/best_index_table.txt', 'w') as f:
    f.write(tabulate(best_table_data, headers=headers, tablefmt='orgtbl'))

with open('figures/clustering/test_validity_indices_matlab/ARI_corr_table.txt', 'w') as f:
    f.write(tabulate(pearsons_coefficient_table_data, headers=headers, tablefmt='orgtbl'))
 


