from dataclasses import dataclass
import sys
import subprocess
import pathlib
import os

number_series_path = pathlib.Path('./build/number_series.exe')
plusser_path       = pathlib.Path('./plusser.py')

@dataclass
class Min_max:
  min: int
  max: int

steps_range = Min_max(min=15, max=25)

def min_max2argv(min_max: Min_max)->list[str]:
  return [str(min_max.min), str(min_max.max)]

def get_obf_lines()->list[str]:
  obf_lines: list[str] = []
  for argv in sys.argv[1:]:
    int(argv)
    result = subprocess.run([number_series_path, argv] + min_max2argv(steps_range), stdout=subprocess.PIPE, text=True)
    result.check_returncode()
    result = subprocess.run(['python', plusser_path], input=result.stdout.strip(), stdout=subprocess.PIPE, text=True)
    result.check_returncode()
    obf_lines.append(result.stdout)
  return obf_lines

with open("obfusc_numbers.txt", "w") as f:
  for line in get_obf_lines():
    f.write(line)
