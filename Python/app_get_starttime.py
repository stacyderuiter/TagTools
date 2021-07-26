from tagiofuns.nc import load_nc
from tagiofuns.get_start_time import get_start_time

# myfile = load_nc(fname='D:\\tagtools\\Python\\test_data\\be190426-57_prh10.nc')
myfile = load_nc(fname='D:\\tagtools\\Python\\test_data\\testset3.nc')
info = myfile['info']

t = get_start_time(info)
print(t)