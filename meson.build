project('number_series', 'cpp', default_options : ['cpp_std=c++23'])

incdir = [include_directories('./inc/')]
catch_dep = []

src_unit_test_files = [
]
src_dir = './src/'

foreach file : src_unit_test_files
  path = src_dir / file
  exe = executable(file, sources : path,
      include_directories : incdir,
      cpp_args : ['-DUNIT_TEST'],
      dependencies : catch_dep)
  test(file, exe)
endforeach

src_all_files = src_unit_test_files + [
    'main.cpp',
]

path_src = []

foreach file : src_all_files
  path_src += src_dir / file
endforeach

exe_name = 'number_series'
executable(exe_name, sources : path_src, include_directories : incdir, install: true)

src_standalone_test_files = {
}

standalone_test_dir = 'test'

foreach test_file, other_files : src_standalone_test_files
  test_file_path = standalone_test_dir / test_file
  all_src_path = [test_file_path] + other_files
  exe = executable(test_file, sources : all_src_path,
      include_directories : incdir,
      dependencies : catch_dep)
  test(test_file, exe)
endforeach
