#!/bin/env python

import numpy as np


print "this is showing if how to use numpy lib to make NLP vectorization"

#layer_number = 4
#layer_data_number = 4
layer_data = np.array([1,2,3,4,5])
#layer_parameter= np.array([[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]])
#
#
print "\nlayer_data:"
print layer_data
#
#print "\nlayer_data.reshape(1,5):"
#print layer_data.reshape(1,5)
#
#print "\nlayer_data.reshape(5,1):"
#print layer_data.reshape(5,1)
#
#print "\nlayer_data.reshape(1,5):"
#print layer_data.reshape(1,5)
#
#print "\nlayer_parameter:"
#print layer_parameter
#
#print "\nlayer_parameter.reshape(5,5):"
#print layer_parameter.reshape(5,5)
#
#print "\nnp.dot(layer_parameter,layer_data.reshape(5,1)):"
#print np.dot(layer_parameter,layer_data.reshape(5,1))


#for i in range(layer_number):
#    layer_parameter[i],layer_data[i].reshape(5,1)).reshape(1,5)
#    print layer_data[i+1]

# 2-D array: 2 x 3
#tmp1 = np.array([[1, 2, 3], [4, 5, 6]])
#two_dim_matrix_one = np.array([tmp1, tmp2])
tmp=[]
tmp.append(np.random.random(size=(2,3)))
#tmp.append(tmp1)
#tmp.append(tmp2)
#tmp.append(tmp3)
print('two_dim_matrix_one:')
#print two_dim_matrix_one
print tmp[0]

two_dim_matrix_one = np.array(tmp)

#two_dim_matrix_two = np.array([[[1], [1], [1]],[[2], [2], [2]]])
two_dim_matrix_two = np.array([([1], [1], [1]),([2], [2], [2]),([3],[3],[3])])
#tmp1=[]
#tmp1.append(np.random.random(size=(3,1)))
#tmp1.append(np.random.random(size=(3,1)))
#tmp1.append(np.random.random(size=(3,1)))
#two_dim_matrix_two = np.array(tmp1)
print('two_dim_matrix_two:')
print two_dim_matrix_two
two_dim_matrix_two = np.array([[[1], [1], [1]],[[2], [2], [2]],[[3],[3],[3]]])
print('two_dim_matrix_two:')
print two_dim_matrix_two

#two_multi_res = np.dot(two_dim_matrix_one, two_dim_matrix_two)
two_multi_res = np.dot(tmp[0], two_dim_matrix_two)
print('two_multi_res:')
print two_multi_res
print('two_multi_res.-1,2:')
print two_multi_res.reshape(-1,1)
