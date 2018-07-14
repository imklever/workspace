#!/bin/env python
# -*- coding: utf-8 -*-

import sys
import xlsxwriter


if 2 != len(sys.argv):
    print "unit_format.py <number[with unit]>"
    exit(1)



sds_number=2



excel = xlsxwriter.Workbook("fio.xlsx")
excel_sheet1 = excel.add_worksheet("sheet_name")
excel_sheet2 = excel.add_worksheet("sheet_name2")
excel_sheet3 = excel.add_worksheet("sheet_name3")

#attribute
bold = excel.add_format({"bold":True})
attr = excel.add_format({"bold":True})


#############################################
#读入数据
#############################################
fp = open(sys.argv[1])

title = fp.readline().split()
data  = fp.readline().split()
data  = [ float(x) for x in data ]

print title
print data



#############################################
#写入excel文件
#############################################
excel_sheet1.write(0,0,"disk",bold)
excel_sheet1.write(1,0,"iops",bold)

excel_sheet1.write_row(0,1,title)
excel_sheet1.write_row(1,1,data)


#############################################
#chart  插入图表：条形图、柱状图、饼图等
#############################################

#############################################
chart1=excel.add_chart({'type':'column'})

chart1.add_series({
    'name':'SSD & HDD',
    'categories':'=sheet_name!$B$1:$N$1',
    'values':'=sheet_name!$B$2:$N$2',
    })
#chart1.add_series({
#    'name':'date2',
#    'categories':'=sheet_name!$A$1:$G$1',
#    'values':'=sheet_name!$C$3:$C$9',
#    })
chart1.set_title({'name':'IOPS'})
chart1.set_x_axis({'name':'disk name'})
chart1.set_y_axis({'name':'IOPS'})
#chart1.set_style(12)
#chart1.set_style(13)
excel_sheet1.insert_chart('A3',chart1,{'x_offset':0,'y_offset':0})


#############################################
chart2=excel.add_chart({'type':'column'})

chart2.add_series({
    'name':'SSD',
    'categories':'=sheet_name!$B$1:$C$1',
    'values':'=sheet_name!$B$2:$C$2',
    })
chart2.set_title({'name':'IOPS'})
chart2.set_x_axis({'name':'disk name'})
chart2.set_y_axis({'name':'IOPS'})
#chart2.set_style(12)
#chart2.set_style(13)
excel_sheet1.insert_chart('I3',chart2,{'x_offset':0,'y_offset':0})


#############################################
chart3=excel.add_chart({'type':'column'})

chart3.add_series({
    'name':'HDD',
    'categories':'=sheet_name!$D$1:$N$1',
    'values':'=sheet_name!$D$2:$N$2',
    })
chart3.set_title({'name':'IOPS'})
chart3.set_x_axis({'name':'disk name'})
chart3.set_y_axis({'name':'IOPS'})
#chart3.set_style(12)
#chart3.set_style(13)
excel_sheet1.insert_chart('Q3',chart3,{'x_offset':0,'y_offset':0})

#############################################
#结束处理
#############################################
excel_sheet1.activate()


excel.close()
exit(1)

#data
#title = ["name","gender","email","address","login time","logout time","mark".decode("utf-8")]
#data = ["linda","femal","some@some.com","shanghai","20170711095600","never","hello"]



#############################################
#meyhod 2
#############################################
for i in range(2,9):
	print i, 0
	excel_sheet1.write(i, 0, "No."+str(i), bold)
	excel_sheet1.write(i, 1, i)
	excel_sheet1.write(i, 2, i+1)


#############################################
#meyhod 3
#############################################
excel_sheet1.write_row('A11',title,bold)
excel_sheet1.write_row('A12',data)

excel_sheet1.write_column('A14',title,bold)
excel_sheet1.write_column('B14',data)





#############################################
#chart  插入图表：条形图、柱状图、饼图等
#############################################

chart1=excel.add_chart({'type':'column'})

chart1.add_series({
    'name':'date1',
    'categories':'=sheet_name!$A$3:$A$9',
    'values':'=sheet_name!$B$3:$B$9',
    })
chart1.add_series({
    'name':'date2',
    'categories':'=sheet_name!$A$1:$G$1',
    'values':'=sheet_name!$C$3:$C$9',
    })

chart1.set_title({'name':'hello'})
chart1.set_x_axis({'name':'x_axis'})
chart1.set_y_axis({'name':'y_axis'})

#chart1.set_style(12)
#chart1.set_style(13)

excel_sheet1.insert_chart('H13',chart1,{'x_offset':25,'y_offset':10})


excel_sheet1.activate()

























excel.close()
