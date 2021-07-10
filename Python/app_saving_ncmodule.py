from tagiofuns.nc import load_nc, add_nc, save_nc, remove_nc
import os

fname = 'D:\\projects\\TagTools\\Python\\test_data\\testset3.nc'
# print(os.path.exists(fname))

myfile = load_nc(fname)
print(myfile.keys())

newname = 'D:\\projects\\TagTools\\Python\\test_data\\testset3_copy.nc'
# # saving with a set of dictionaries
# save_nc(newname,myfile,1)
# if os.path.exists(newname):
#     newfile = load_nc(newname)
#     print(newfile.keys())

# # saving with a single dictionary
# save_nc(newname,myfile['PCA'],1)
# if os.path.exists(newname):
#     newfile = load_nc(newname)
#     print(newfile.keys())

# saving with several separate dictionaries, then removing one
save_nc(newname,myfile['PCA'],myfile['A'],myfile['P'])
if os.path.exists(newname):
    newfile = load_nc(newname)
    print(newfile.keys())
    # remove a variable
    remove_nc(newname,'PCA')
    newfile = load_nc(newname)
    print(newfile.keys())
