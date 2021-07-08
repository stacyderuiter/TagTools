from tagiofuns.load_nc import load_nc
from tagiofuns.sens2var import sens2var

myfile = load_nc('D:\\projects\\TagTools\\Python\\test_data\\testset3.nc')
# reg = sens2var(myfile['PCA'],'regular')
# if reg:
#     print('PCA is regular')
X,Y,fs = sens2var(myfile['P'],myfile['A'])
print(X.shape, Y.shape)