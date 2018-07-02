#!/bin/env python
# -*- coding: utf-8 -*-

import xlsxwriter

excel = xlsxwriter.Workbook("excel_name.xlsx")
excel_sheet1 = excel.add_worksheet("sheet_name")
excel_sheet2 = excel.add_worksheet("sheet_name2")
excel_sheet3 = excel.add_worksheet("sheet_name3")

#attribute
bold = excel.add_format({"bold":True})

#data
title = ["name","gender","email","address","login time","logout time","mark".decode("utf-8")]
data = ["linda","femal","some@some.com","shanghai","20170711095600","never","hello"]


#############################################
#meyhod 1
#############################################
#intex
title_index = ["A","B","C","D","E","F","G"]
#title
for i,j in enumerate(title_index):
	position = "%s%s"%(j,1)
	print position
	content = title[i]
	excel_sheet1.write(position,content,bold)
#data
for i,j in enumerate(title_index):
	position = "%s%s"%(j,2)
	content = data[i]
	excel_sheet1.write(position,content)



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
