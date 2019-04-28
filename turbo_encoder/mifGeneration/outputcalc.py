import random

LENGTH_1 = 1056
LENGTH_2 = 6144


def calc(inputstr):
    d0 = 0
    d1 = 0
    d2 = 0
    out = ""
    for i in range(len(inputstr)):
        char = inputstr[i]
        bit = int(char)
        xorbottom = d1^d2
        xorfront = xorbottom^bit
        xortop1 = xorfront^d0
        xortop2 = xortop1^d2
        if i < len(inputstr)-1:
            d2 = d1
            d1 = d0
            d0 = xorfront

        out += str(xortop2)

    return out, d0, d1, d2


def term(q2, q1, q0, p2, p1, p0):
    zkterm = ""
    zkterm += str(q0 ^ q2)
    zkterm += str(q2)
    zkterm += str(p2 ^ p0)
    zkterm += str(p2)

    xktermination = ""
    xktermination += str(q0 ^ q1)
    xktermination += "0"
    xktermination += str(p0 ^ p1)
    xktermination += "0"

    zkpterm = ""
    zkpterm += str(q2 ^ q1)
    zkpterm += str(0)
    zkpterm += str(p2 ^ p1)
    zkpterm += str(0)

    return xktermination, zkterm, zkpterm


def doOneCycle(ck, ckp):
    xk = ck
    zk, d0, d1, d2 = calc(ck)
    zkp, p0, p1, p2 = calc(ckp)

    termArr = term(d0, d1, d2, p0, p1, p2)
    xk += termArr[0]
    zk += termArr[1]
    zkp += termArr[2]

    return xk, zk, zkp


def padZeros(data, length):
    return data.ljust(length, "0")


def write(filename, bits):
    with open(filename, "w+") as outfile:
        header = """WIDTH=1;
DEPTH={};
        
ADDRESS_RADIX=DEC;
DATA_RADIX=HEX;

CONTENT BEGIN
"""
        entry = "{}:{};\n"
        tail = "END;"
        bitstowrite = bits.replace("\n", "")
        outfile.write(header.format(len(bitstowrite)))
        i = 0
        for bit in bitstowrite:
            outfile.write(entry.format(i,bit))
            i+=1
        outfile.write(tail)


def generate_rand(length):
    ret = ""
    for _ in xrange(length):
        ret += str(random.randint(0,1))
    return ret

#
# with open("ckin.txt", "r") as ckfile:
#     with open("ckpin.txt", "r") as ckpfile:
#         ckinput = ckfile.readline()
#         ckpinput = ckpfile.readline()


desired_length=LENGTH_1+LENGTH_2
ckinput = generate_rand(desired_length)
ckpinput = generate_rand(desired_length)
ck1 = ckinput[:LENGTH_1]
ck2 = ckinput[LENGTH_1:]
ckp1 = ckpinput[:LENGTH_1]
ckp2 = ckpinput[LENGTH_1:]

xk1, zk1, zkp1 = doOneCycle(ck1, ckp1)
xk2, zk2, zkp2 = doOneCycle(ck2, ckp2)
x = len(xk1+xk2)
ckout = padZeros(ckinput, len(xk1+xk2))
p = len(ckout)
ckpout = padZeros(ckpinput, len(xk1 + xk2))
write("zk.mif", zk1 + zk2)
write("zkp.mif", zkp1 + zkp2)
write("xk.mif", xk1 + xk2)
write("ck.mif", ckout)
write("ckp.mif", ckpout)

