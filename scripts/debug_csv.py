import sys

with open(sys.argv[1],'r') as f:
    for lineix,line in enumerate(f):
        print(str(lineix)+' '+str(len(line.strip().split())))
