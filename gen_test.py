import random
import struct

def float_to_bin(x):
  return int.from_bytes(struct.pack('f', x), "little")

COUNT = 16
data = [random.randrange(int(-1e8), int(1e8)) / 1e4 for _ in range(COUNT)]
floats = [f"'b{float_to_bin(i):b}" for i in data]

result = sum(data)
result_b = float_to_bin(result)

print(f"integer test_sum = 'b{result_b:b}; // {result}")
arr = "{" + ', '.join(floats) + "}"
print(f'logic[31:0] source_data [$] = {arr};')

