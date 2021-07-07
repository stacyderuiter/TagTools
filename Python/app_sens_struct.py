from tagiofuns.sens_struct import sens_struct

from scipy.io import loadmat
fname = '.\\test_data\\testset4.mat'
annots = loadmat(fname)
A = [[element for element in upperElement] for upperElement in annots['A']]
fs = 100
depid = 'furka'
sens_type = 'acc'

Ad = sens_struct(A,fs,depid,sens_type)
print(Ad)