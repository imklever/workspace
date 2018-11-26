#!/bin/env python
# -*- coding=utf-8 -*-

import numpy as np


print "this is a real  NLP program demo"

layer_number = 9
#layer_data = np.array([
#    [1,2,3,4,5],
#    [1,2,3,4,5],
#    [1,2,3,4,5],
#    [1,2,3,4,5],
#    [1,2]])
#layer_parameter= np.array([
#    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]],
#    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]],
#    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]],
#    [[1,2,3,4,5],[1,2,3,4,5]]])

#nur_num=[9,5,5,5,2]



#########################
#设置各层神经元数
#########################

#输入层
nur_num=[2]

#中间层
for i in range(1,layer_number):
    nur_num.append(2)

#输出层
nur_num.append(2)


layer_data=[]
layer_parameter=[]



#########################
#分配各层神经元数
#########################
for i in range(layer_number+1):
    layer_data.append(np.zeros((nur_num[i],1),np.int))

print "layer_data"
for i in layer_data:
    print i.reshape(1,-1)


#########################
#初始化输入层神经元值
#########################
layer_data[0]=np.random.random(size=(nur_num[0],1))

print "layer_data"
for i in layer_data:
    print i.reshape(1,-1)


#########################
#初始化每两层神经元之间的
#权重  & 偏置
#########################
layer_b=[]
for i in range(layer_number):
    layer_parameter.append(np.random.random(size=(nur_num[i+1],nur_num[i])))
    layer_b.append(np.random.random(size=(nur_num[i+1],1)))

print "layer_b"
for i in layer_b:
    print i.reshape(1,-1)



#########################
#前向传递：
#计算每层神经元的值
#########################
for i in range(layer_number):

    print "\n"
    print "last layer"
    print layer_data[i].reshape(1,-1)

    #layer_data[i+1] = np.dot(layer_parameter[i],layer_data[i])+layer_b[i]

    layer_data[i+1] = np.dot(layer_parameter[i],layer_data[i])

    print "next layer before b"
    print layer_data[i+1].reshape(1,-1)

    layer_data[i+1] += layer_b[i]

    print "next layer after b"
    print layer_data[i+1].reshape(1,-1)

