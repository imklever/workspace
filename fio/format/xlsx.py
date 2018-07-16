#!/bin/env python
# -*- coding: utf-8 -*-

import sys
import xlsxwriter


if 2 != len(sys.argv):
    print "unit_format.py <excel filename> <number[with unit]>"
    exit(1)



filename="./xlsx/performance.xlsx"
sds_number=2

print filename

excel = xlsxwriter.Workbook(filename)

#attribute
title_attr = excel.add_format({"bold":True,'bg_color': '00ff00'})
disk_attr = excel.add_format({'font_color': 'red', 'align':'left'})
data_attr = excel.add_format({'font_color': 'red', 'align':'left'})


fp = open(sys.argv[1])

while 1:
    #############################################
    #读入数据
    #############################################
    info=fp.readline()
    if not info:
        break
    print info.strip()," log processing ..."
    ssd_number=fp.readline().strip()
    performance_name=fp.readline().strip()
    x_axis=fp.readline().strip()
    y_axis=fp.readline().strip()
    title = fp.readline().strip().split()
    data  = fp.readline().strip().split()
    data  = [ float(x) for x in data ]
    
    #############################################
    #创建sheet
    #############################################
    excel_sheet = excel.add_worksheet(performance_name)
    
    
    #############################################
    #写入excel文件
    #############################################
    excel_sheet.write(0,0,"disk",title_attr)
    excel_sheet.write(1,0,performance_name,title_attr)
    
    excel_sheet.write_row(0,1,title)
    excel_sheet.write_row(1,1,data,data_attr)
    
    
    
    #############################################
    #chart  插入图表：条形图、柱状图、饼图等
    #############################################
    
    #############################################
    chart1=excel.add_chart({'type':'column'})
    
    chart_categories="="+performance_name+"!$B$1:$N$1"
    chart_value     ="="+performance_name+"!$B$2:$N$2"
    chart1.add_series({
        'name':'SSD & HDD',
        'categories':chart_categories,
        'values':chart_value,
        })
    #chart1.add_series({
    #    'name':'date2',
    #    'categories':'=sheet_name!$A$1:$G$1',
    #    'values':'=sheet_name!$C$3:$C$9',
    #    })
    chart1.set_title({'name':performance_name})
    chart1.set_x_axis({'name':x_axis})
    chart1.set_y_axis({'name':y_axis})
    excel_sheet.insert_chart('A3',chart1,{'x_offset':0,'y_offset':0})
    
    
    #############################################
    chart2=excel.add_chart({'type':'column'})
    
    chart_categories="="+performance_name+"!$B$1:$C$1"
    chart_value     ="="+performance_name+"!$B$2:$C$2"
    chart2.add_series({
        'name':'SSD',
        'categories':chart_categories,
        'values':chart_value,
        })
    chart2.set_title({'name':performance_name})
    chart2.set_x_axis({'name':x_axis})
    chart2.set_y_axis({'name':y_axis})
    excel_sheet.insert_chart('I3',chart2,{'x_offset':0,'y_offset':0})
    
    
    #############################################
    chart3=excel.add_chart({'type':'column'})
    
    chart_categories="="+performance_name+"!$D$1:$N$1"
    chart_value     ="="+performance_name+"!$D$2:$N$2"
    chart3.add_series({
        'name':'HDD',
        'categories':chart_categories,
        'values':chart_value,
        })
    chart3.set_title({'name':performance_name})
    chart3.set_x_axis({'name':x_axis})
    chart3.set_y_axis({'name':y_axis})
    excel_sheet.insert_chart('Q3',chart3,{'x_offset':0,'y_offset':0})
    print info.strip()," log process finished\n"

#############################################
#结束处理
#############################################
excel_sheet.activate()


excel.close()
