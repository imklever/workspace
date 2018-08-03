#!/bin/env python

import numpy as np


print "show how to use matrix"

layer_data = np.array([
    [1,2,3,4,5],
    [1,2,3,4,5],
    [1,2,3,4,5],
    [1,2,3,4,5],
    [1,2,3,4,5]])
layer_parameter= np.array([
    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]],
    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]],
    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]],
    [[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]]])



data=np.array([[1,2,3,4,5]])
print "\n"
print "data:"
print data

print "\n"
print "data.T:"
dataT = data.T
print dataT


print "\n"
print ("data dot data.T:")
print np.dot(data,dataT)

print "\n"
print ("dataT dot data:")
print np.dot(dataT,data)


print "\n"
print ("parameter:")
print layer_parameter[0]

print "\n"
print ("parameter dot data.T:")
print np.dot(layer_parameter[0],data.T)


data=np.array([
    [[1.1,1.2,1.3,1.4,1.5],[2.1,2.2,2.3,2.4,2.5]],
    [[3.1,3.2,3.3,3.4,3.5],[4.1,4.2,4.3,4.4,4.5]]])
print "\n"
print "data:"
print data


data=np.array([
    [[1.1,1.2,1.3,1.4,1.5],[2.1,2.2,2.3,2.4,2.5]],
    [[3.1,3.2,3.3,3.4,3.5],[4.1,4.2,4.3,4.4,4.5]]]).T


print "\n"
print "data:"
print data
print data
