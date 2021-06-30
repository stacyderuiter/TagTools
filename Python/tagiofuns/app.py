from load_nc import load_nc
import matplotlib.pyplot as plt

X = load_nc()
# print(X)
plt.plot(X['P']['data'])
plt.gca().invert_yaxis()
plt.show()