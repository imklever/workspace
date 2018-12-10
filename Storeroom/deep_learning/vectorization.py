#!/bin/env python

import numpy as np
import time


print "this is showing if how to use numpy lib to make vectorization"

a = np.random.rand(1000000)
b = np.random.rand(1000000)



tic = time.time()
c = np.dot(a,b)
toc = time.time()
print "this is the time spend by the vectorization program:"
print ("time: %s" % (1000*(toc-tic)))
print ""



#c = 0
#tic = time.time()
#for i in range(1000000):
#    c += a[i]*b[i]
#toc = time.time()
#print "this is the time spend by the for loop program:"
#print ("time: %s" % (1000*(toc-tic)))




u = np.array([
    [1,2,3,4,5],
    [5,6,7,8,9]])
print "matrix:"
print u
print ""



d = np.array([1,2,3,4,5])
print "vector:"
print d
print ""



v = np.dot(u[0],d)
print "matrix dot multiply vector:"
print v
print ""



v = np.square(u)
print "square of matrix:"
print v
print ""



cal = u.sum(axis=0)
print "sum of matrix:"
print cal
print ""



percentage = 100*u/(cal.reshape(1,5))
print "percentage of matrix:"
print percentage
print ""







