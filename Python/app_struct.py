from tagiofuns.csv2struct import csv2struct

dirpath = 'D:\\tagtools\\Python\\test_data\\'
fname = 'testset1'

S = csv2struct(dirpath,fname)
print(S['depid'])