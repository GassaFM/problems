n = 100
f = [1, 2]
while len (f) <= n:
	f += [f[-2] + f[-1]]
for i, c in enumerate (f):
	print bin (c), len (bin (c)) - 2, i + 1, c
