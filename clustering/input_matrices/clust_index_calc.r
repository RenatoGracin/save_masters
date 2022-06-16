library(R.matlab)
library(NbClust)
library(fpc)
library(dbscan)

matlab_data <- readMat("optics_artficial_data.mat")

dataset_ind <- 2 #:6

# # check out data structure
x <- matlab_data[[1]][[dataset_ind]][[1]]
row_len <- length(x)/2
str(x[1:row_len,1])

# matplot(matlab_data[[1]][[1]][[1]][1:1500,2])
plot(x)
# # set.seed(2)
# # n <- 400

# # x <- cbind(
# #   x = runif(4, 0, 1) + rnorm(n, sd = 0.1),
# #   y = runif(4, 0, 1) + rnorm(n, sd = 0.1)
# #   )

# plot(x, col=rep(1:4, time = 100))
eps <- max(kNNdist(x, k = 10))
kNNdist(x, k = 10)
## run OPTICS (Note: we use the default eps calculation)
# res <- optics(x, minPts = 10)
# # res

# ## get order
# # res$order

# ## plot produces a reachability plot
# plot(res)

# ## plot the order of points in the reachability plot
# plot(x, col = "grey")
# polygon(x[res$order, ])

# ## extract a DBSCAN clustering by cutting the reachability plot at eps_cl
# res <- extractDBSCAN(res, eps_cl = .065)
# # res

# plot(res)  ## black is noise
# hullplot(x, res)

# # ## re-cut at a higher eps threshold
# # res <- extractDBSCAN(res, eps_cl = .07)
# # res
# # plot(res)
# # hullplot(x, res)

# # ### extract hierarchical clustering of varying density using the Xi method
# res <- extractXi(res, xi = 0.17)
# # # res

# # # plot(res)
# hullplot(x, res)

# # Xi cluster structure
# # res$clusters_xi

# # ## use OPTICS on a precomputed distance matrix
# # d <- dist(x)
# # res <- optics(d, minPts = 10)
# # plot(res)

# # print("Done")