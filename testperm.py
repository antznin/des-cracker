import sys
input1 = sys.argv[1]
input2 = sys.argv[2]

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

def pc2(inp):
    output = \
        inp[13] + inp[16] + inp[10] + inp[23] + inp[0] + inp[4] + inp[2] + inp[27] +\
        inp[14] + inp[5] + inp[20] + inp[9] + inp[22] + inp[18] + inp[11] + inp[3] + inp[25] +\
        inp[7] + inp[15] + inp[6] + inp[26] + inp[19] + inp[12] + inp[1] + inp[40] + inp[51]+\
        inp[30] + inp[36] + inp[46] + inp[54] + inp[29] + inp[39] + inp[50] + inp[44] + \
        inp[32] + inp[47] + inp[43] + inp[48] + inp[38] + inp[55] + inp[33] + inp[52] + \
        inp[45] + inp[41] + inp[49] + inp[35] + inp[28] + inp[31]
    return output

print(pc2(list(reversed(input1 + input2))))
