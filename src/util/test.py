#!/usr/bin/env python3
import base64
input = "Python 3.10.10 (main, Mar  5 2023, 22:26:53) [GCC 12.2.1 20230201] on linux"
key = "key123"
input_bytes = bytes(input, "utf8")
key_bytes = bytes(key, "utf8")
print("input:", input, "bytes:", input_bytes.hex())
print("key:", key, "bytes:", key_bytes.hex())
output = bytearray()
for i in range(len(input_bytes)):
    output.append(input_bytes[i] ^ key_bytes[i % len(key_bytes)])
print("output:", base64.b64encode(output).hex())
reverse = bytearray()
for i in range(len(input_bytes)):
    reverse.append(output[i] ^ key_bytes[i % len(key_bytes)])
print("decoded:", reverse.decode('utf8'))
