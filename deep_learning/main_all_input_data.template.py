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



#########################
#初始化输入层神经元值,
#包括所有的输入样例,
#即包括所有输入向量
#########################
sample_number=4
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



#########################
#将所有的输入 样例 / 向量
#进行向量化
#########################
layer_Data=np.array(tmp_data)

#print "layer_Data"
#print layer_Data



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
#print layer_b"






#########################
#前向传递：
#计算每层神经元的值
#########################
for layer in range(layer_number):

    print "\n"
    print "last layer_Data"
    print layer_Data
    print "\n"

    print "layer_parameter[layer]"
    print layer_parameter[layer]
    print "\n"

    #layer_Data1 = layer_Data
    #layer_Data1  = np.dot(layer_parameter[layer],layer_Data1)
    layer_Data = np.dot(layer_parameter[layer],layer_Data).T.reshape(sample_number,-1,1)


    print "next layer before b"

    print "layer_Data"
    print layer_Data
    print "\n"

    #print "layer_Data1"
    #print layer_Data1
    #print "\n"

    print "layer_b[layer]"
    print layer_b[layer]
    print "\n"

    print "next layer after b"
    layer_Data += layer_b[layer]
    print layer_Data

    print "\n\n\n\n"




#########################
#计算损失函数：
#########################




#########################
#反向传递：
#更新每层神经元的 权重 & 偏置
#########################

