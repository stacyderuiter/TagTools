from tagiofuns.read_cats_csv import read_cats_csv

# fname = 'D:\\tagtools\\matlab\\tagiofuns\\cats_test_segment'
fname = 'D:\\tagtools\\matlab\\tagiofuns\\20170622-060212-Frotwok 38'
V,HDR,EMPTY = read_cats_csv(fname)

print(HDR)
print(EMPTY)
print(V.shape)
print(V[-1,:])