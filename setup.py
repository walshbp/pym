from distutils.core import setup
from Cython.Build import cythonize
from distutils.core import setup, Extension

compile_args = ['-g', '-std=c++11', '-fpermissive', '-g']

base_path = '/home/bwalsh/proj/install'
base_path = '/home/bryan/projectm_install'
basics_module = Extension('pym',
                sources=['pym.pyx'],
                include_dirs = [base_path + '/include/'],
                library_dirs = [base_path + '/lib/'],
                runtime_library_dirs = [base_path + '/lib/'],
                libraries = ['projectM'],
                extra_compile_args=compile_args,
                language='c++')

setup(
    name='pym',
    ext_modules=cythonize(basics_module)
)


