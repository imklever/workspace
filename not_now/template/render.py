#!/bin/env python
#! -*- coding=utf-8 -*-

import jinja2
from jinja2 import Environment,PackageLoader

# 创建一个包加载器对象
env = Environment(loader=PackageLoader('template_project','templates'))

# 获取一个模板文件
template = env.get_template('temp')

my_list1=[]
my_list1.append([{'name':'alice','age':18}])
my_list1.append([{'name':'bob','age':19}])
my_list1.append([{'name':'john','age':20}])
# 渲染
content = template.render(name='haha', age=180, my_list=my_list1)

print content
