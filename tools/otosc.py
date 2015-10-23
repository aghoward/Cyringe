#!/usr/bin/python

##
#  Takes as input the ouput from:
#  objdump -Dz | grep "[0-9a-f]*?:" | cut -c 1,2
import sys

def main(inputs, outputfile):
    lines = [x.strip(" ") for x in inputs.split("\n")]
    barray = b""

    for line in lines:
        line = line.replace("\t", " ")
        datas = [x.strip(" :") for x in line.split(" ")]

        index = int(datas[0], 16)
        barray = barray[:index] + bytes([int(x, 16) for x in datas[1:]])

    with open(outputfile, "wb") as fd:
        fd.write(barray)

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print ("Usage: {0} inputstring outputfile".format(sys.argv[0]))
        exit()
    main(sys.argv[1], sys.argv[2])
