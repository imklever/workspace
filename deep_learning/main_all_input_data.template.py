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
nur_num=[3]

#中间层
for i in range(1,layer_number):
    nur_num.append(3)

#输出层
nur_num.append(5)

#########################
#分配各层神经元数
#########################
layer_data=[]
for i in range(layer_number+1):
    layer_data.append(np.zeros((nur_num[i],1),np.int))



#########################
#初始化输入层神经元值,
#包括所有的输入样例,
#即包括所有输入向量
#########################

sample_number=4
tmp_data=[]

#样例1~n
tmp_data.append(np.random.random(size=(nur_num[0],1)))
tmp_data.append(np.random.random(size=(nur_num[0],1)))
tmp_data.append(np.random.random(size=(nur_num[0],1)))
tmp_data.append(np.random.random(size=(nur_num[0],1)))
#样例...



#########################
#将所有的输入 样例 / 向量
#进行向量化
#########################
layer_Data=np.array(tmp_data)




#########################
#初始化每两层神经元之间的
#权重  & 偏置
#########################
layer_parameter=[]
layer_b=[]
for i in range(layer_number):
    layer_parameter.append(0.01 * np.random.randn(nur_num[i+1],nur_num[i]))
    layer_b.append(np.zeros((nur_num[i+1],1),np.int))




#########################
#自定义ufunc函数：
#激活函数
#########################

#ReLU_limit = 6
#def ReLU(number_in):
#    #return number_in
#    if number_in > 0 and number_in < ReLU_limit:
#        return number_in
#    elif number_in >= ReLU_limit:
#        return ReLU_limit
#    else:
#        return 0

def ReLU(number_in):
    if number_in > 0:
        return number_in
    else:
        return 0

ReLU_ufunc = np.frompyfunc(ReLU,1,1)







#########################
#前向传递：
#计算每层神经元的值
#########################
print layer_Data
for layer in range(layer_number):

    print "------------------------------------------------------"

    print "layer_parameter[layer]"
    print layer_parameter[layer]
    print "\n"

    print "layer_b[layer]"
    print layer_b[layer]
    print "\n"

    print "---"
    layer_Data = np.dot(layer_parameter[layer],layer_Data).T.reshape(sample_number,-1,1)
    print "after parameter"
    print layer_Data

    print "---"
    print "after b"
    layer_Data += layer_b[layer]
    print layer_Data

    print "---"
    print "after ReLU"
    layer_Data = ReLU_ufunc(layer_Data).astype(np.float)
    print layer_Data





#########################
#计算损失函数：
#########################




#########################
#反向传递：
#更新每层神经元的 权重 & 偏置
#########################

