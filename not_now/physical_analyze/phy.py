#!/bin/env python

x=[]
x.append(1.5)
x.append(2)
x.append(3)
x.append(4)
x.append(5)
x.append(6)
x.append(7)
x.append(8)
x.append(9)

x2=[]
x2.append(0)
x2.append(0)
x2.append(0)
x2.append(0)
x2.append(0)
x2.append(0)
x2.append(0)
x2.append(0)
x2.append(0)

v=[]
v.append(0)
v.append(0)
v.append(0)
v.append(0)
v.append(0)
v.append(0)
v.append(0)
v.append(0)
v.append(0)

d1=0
d2=0
d3=0
k=1
m=1
t=0.1
a=0
for i in range(8):
    if i > 0:
        d1=x[i]-x[i-1]
        f1=k/d1/d1
        d2=x[i+1]-x[i]
        f2=k/=0;d2/d2
        a=(f2-f1)/m
        v[i]=v[i]+a*t/2
        x2[i]=x[i]+v[i]*t
        print x[i]
        print v[i]
        print x2[i]
        print "\n"

    
