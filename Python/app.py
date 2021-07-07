from tagiofuns.load_nc import load_nc
# from load_nc import load_nc
import matplotlib.pyplot as plt

X = load_nc()
print(X['A']['data'])
# print(X)
# plt.plot(X['P']['data'])
# plt.show()