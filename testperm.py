import sys
input = sys.argv[1]
input = list(reversed(input))

def C(input):
    output = input[56] + input[48] + input[40] + input[32] + input[24] + input[16] + input[8] + input[0] + input[57] + \
    input[49] + input[41] + input[33] + input[25] + input[17] + input[9] + input[1] + input[58] + input[50] + input[42] \
    +input[34] + input[26] + input[18] + input[10] + input[2] + input[59] + input[51] + input[43] + input[35]
    return output

def D(input):
    output = input[62] + input[54] + input[46] + input[38] + input[30] + input[22] +\
    input[14] + input[6] + input[61] + input[53] + input[45] + input[37] + input[29] +\
    input[21] + input[13] + input[5] + input[60] + input[52] + input[44] + input[36] + \
    input[28] + input[20] + input[12] + input[4] + input[27] + input[19] + input[11] + input[3]
    return output

print(C(input))
print(D(input))
