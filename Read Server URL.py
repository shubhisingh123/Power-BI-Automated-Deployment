import pandas as pd
import sys

df = pd.read_csv(sys.argv[3])

names = df["Report Name"].tolist()
Col = df[sys.argv[2]].tolist()

name = sys.argv[1]

if name not in names:
    print("No1")
    sys.exit(1)
#Hello
count = 0
for i in names:
    if name == i:
        if count > 0:
            print("No2")
            sys.exit(1)
        count+=1

for i in range(len(names)):
    if name == names[i]:
        print(Col[i])