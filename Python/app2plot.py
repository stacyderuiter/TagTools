# from tagiofuns import load_nc
from tagiofuns.load_nc import load_nc
import matplotlib.pyplot as plt

X = load_nc()
# print(myfiles)
# plt.plot(X['P']['data'])
# plt.show()

from plotting.plott import plott
# fig, axes, h = plott(X['P'])
# print(h)
# plott(X['P'])
out = plott(X['P'])
print(out)
plt.show()