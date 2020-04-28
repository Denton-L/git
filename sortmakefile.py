#!/usr/bin/python3

import sys

plusequals = []

def emptyplusequals():
	for pe in sorted(plusequals):
		print(pe)
	plusequals.clear()

for line in sys.stdin:
	line = line.rstrip('\n')

	if '+=' in line:
		plusequals.append(line)
	else:
		emptyplusequals()
		print(line)
emptyplusequals()
