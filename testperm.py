import sys
input1 = sys.argv[1]

ptable = [16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10, 2, 8, 24,\
		14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25]

etable = [32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9, 8, 9, 10, 11, 12, 13, 12, 13, 14,\
		15, 16, 17, 16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25, 24, 25, 26,\
		27, 28, 29, 28, 29, 30, 31, 32, 1]

def p(inp):
    output = ''
    for i in range(len(ptable)):
        output += inp[ptable[i]-1]
    return output

def e(inp):
    output = ''
    for i in range(len(etable)):
        output += inp[etable[i]-1]
    return output

print(p(input1))
print(e(input1))
