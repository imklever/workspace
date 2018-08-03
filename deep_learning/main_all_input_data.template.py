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

#print "layer_data"
#for i in layer_data:
#    print i.reshape(1,-1)


#########################
#初始化输入层神经元值,
#包括所有的输入样例,
#即包括所有输入向量
#########################
tmp_data=[]
#样例1
tmp_data.append(np.random.random(size=(nur_num[0],1)))
#样例2
tmp_data.append(np.random.random(size=(nur_num[0],1)))
#样例3
tmp_data.append(np.random.random(size=(nur_num[0],1)))
#样例...
#样例n
tmp_data.append(np.random.random(size=(nur_num[0],1)))

#print "layer_data"
#for i in layer_data:
#    print i.reshape(1,-1)


#########################
#将所有的输入 样例 / 向量
#进行向量化
#########################
layer_Data=np.array(tmp_data)

#print "layer_Data"
#for i in layer_Data:
#    print i.reshape(1,-1)

#########################
#初始化每两层神经元之间的
#权重  & 偏置
#########################
layer_b=[]
for i in range(layer_number):
    layer_parameter.append(np.random.random(size=(nur_num[i+1],nur_num[i])))
    layer_b.append(np.random.random(size=(nur_num[i+1],1)))

#print "layer_parameter"
#print layer_parameter

#print "layer_b"
#for i in layer_b:
#    print i.reshape(1,-1)



#########################
#前向传递：
#计算每层神经元的值
#########################
for layer in range(layer_number):

    print "\n"
    print "last layer_Data"
    print layer_Data
    print "layer_parameter[layer]"
    print layer_parameter[layer]
    #for i in layer_Data:
    #    #print i.reshape(1,-1)
    #    print i

    layer_Data1 = np.dot(layer_parameter[layer],layer_Data)
    layer_Data = np.dot(layer_parameter[layer],layer_Data)

    #layer_Data = np.dot(layer_parameter[layer],layer_Data)+layer_b[layer]


    print "next layer before b"

    print "layer_Data1"
    print layer_Data1

    print "layer_Data"
    print layer_Data

    print "layer_Data.T"
    print layer_Data.T

    print "layer_b[layer]"
    print layer_b[layer]

    layer_Data += layer_b[layer]
    
    print "next layer after b"
    for i in layer_Data:
        print i.reshape(1,-1)

