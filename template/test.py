#!/bin/env python
#! -*- coding=utf-8 -*-

import jinja2
from jinja2 import Environment,PackageLoader

# 创建一个包加载器对象
#env = Environment(loader=PackageLoader('python_project','templates'))
env = Environment(loader=PackageLoader('template'))

# 获取一个模板文件
template = env.get_template('temp')

# 渲染
template.render(name='haha',age=180)
