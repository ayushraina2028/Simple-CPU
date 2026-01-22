with open("program.hex") as f:
    lines = f.read().split()

bytes_list = []
for x in lines:
    if x.startswith("@"):
        continue
    bytes_list.append(x)

words = []
for i in range(0, len(bytes_list), 4):
    b0 = bytes_list[i]
    b1 = bytes_list[i+1]
    b2 = bytes_list[i+2]
    b3 = bytes_list[i+3]
    word = b3 + b2 + b1 + b0   # little-endian → big-endian
    words.append(word)

with open("program_words.hex", "w") as f:
    for w in words:
        f.write(w + "\n")

print("Generated program_words.hex")
