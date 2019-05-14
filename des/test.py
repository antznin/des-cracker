import des
import sys

if not des.check():
        sys.exit("Failed")

# Testing multiple values
keys       = [0xf0f0f0f0f0f0f0f0, 0x0f0f0f0f0f0f0f0f, 0xffffffff00000000, 0x00000000ffffffff]
plaintexts = [0xf0f0f0f0f0f0f0f0, 0x0f0f0f0f0f0f0f0f, 0xffffffff00000000, 0x00000000ffffffff]

for k in keys:
    for pl in plaintexts:
        print("Key : " + format(k, '016x') + " Plaintext : " +  format(pl, '016x') +  " Ciphertext : "+\
              format(des.enc(des.ks(k), pl), '016x'))
