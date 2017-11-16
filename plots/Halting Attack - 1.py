import numpy as np
from numpy import exp as exp
from numpy import log as log
import matplotlib.pyplot as plt

colors = ['green', 'orange', 'red','blue', 'cyan']
font = {'family': 'serif',
        'color':  'darkred',
        'weight': 'normal',
        'size': 16,
        }
parameter_space = [(600,1000), (1000,1000), (2000,1000), (20000, 1000), (40000, 1000)]
x = np.linspace(0.0, .5, 200)

def cost(y, b, x_val):
    initial_reserve = b*log(exp(y / b) + exp(5))
    return (b*log(exp(y / b) + exp(5 + (y*(1 - 2*x_val) / b))) - initial_reserve)/initial_reserve

for i in range(len(parameter_space)):
    y = cost(parameter_space[i][0], parameter_space[i][1], x)
    function, = plt.plot(x, y, color=colors[i % len(colors)])
    function.set_label('$y, b$ = ${0}, {1}$'.format(*parameter_space[i]))
    plt.legend()

plt.title('Cost to maliciously halt contract termination', fontdict=font)
#plt.text(8, 0.65, r'$\cos(2 \pi t) \exp(-t)$', fontdict=font)
plt.xlabel('Percentage of sleeping voters', fontdict=font)
plt.ylabel('Percent of reserve initially in contract', fontdict=font)

# Tweak spacing to prevent clipping of ylabel
plt.subplots_adjust(left=0.15)
plt.legend(loc = 'best')
plt.show()
