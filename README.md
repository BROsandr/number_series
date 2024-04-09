# number_series

Transforms a number to series.

Program `number_series` supports two operations: `add`, `xor`. The program prints the series numbers separated by spaces. If you want the numbers to be separated by the operation's sign (`+`, `^`), you can pipeline the output to [`plusser`](./plusser.py)/[`xorer`](./xorer.py) appropriately.


```
help: number_series <number> <min_number_of_steps> <max_number_of_steps> [<op>]
  Range: [<min_number_of_steps>, <max_number_of_steps>)
  <op> is one of: add, xor. The default is add.
```

For example `add`: 5 = 32'o6236621706 + 32'o14417114151 + 32'h66334873 + 32'h314fb63.
For example `xor`: 5 = 32'd23396 ^ 32'd31617 ^ 32'd15129 ^ 32'b00000000000000000001101111111001.
