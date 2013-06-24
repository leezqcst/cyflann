try:
    import numpy
except ImportError:
    raise ImportError("cyflann requires numpy to be installed")
    # Don't do this in the setup() requirements, because otherwise pip and
    # friends get too eager about updating numpy.

try:
    from setuptools import setup
    from setuptools.extension import Extension
except ImportError:
    from distutils.core import setup
    from distutils.extension import Extension

try:
    from Cython.Build import cythonize
except ImportError:
    import os
    try:
        pyx_time = os.path.getmtime('cyflann/flann_index.pyx')
        pxd_time = os.path.getmtime('cyflann/flann.pxd')
        c_time = os.path.getmtime('cyflann/flann_index.c'.format(pkg, name))
        if max(pyx_time, pxd_time) >= c_time:
            raise ValueError
    except (OSError, ValueError):
        msg = "{} extension needs to be compiled but cython isn't available"
        raise ImportError(msg.format(name))
else:
    cythonize("cyflann/flann_index.pyx", "cyflann/flann.pdx")
ext_modules = [
    Extension("cyflann.flann_index", ["cyflann/flann_index.c"],
              extra_link_args=['-lflann'])
]

setup(
    name='cyflann',
    version='0.1.0dev',
    author='Dougal J. Sutherland',
    author_email='dougal@gmail.com',
    packages=['cyflann'],
    url='https://github.com/dougalsutherland/cyflann',
    description='A Cython-based interface to the FLANN nearest neighbors library.',
    long_description=open('README.rst').read(),
    license='LICENSE.txt',
    install_requires=[],
    include_dirs=[numpy.get_include()],
    ext_modules=ext_modules,
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: BSD License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 2 :: Only",
        # TODO: python 3 compatibility
        "Programming Language :: Cython",
        "Programming Language :: Python :: Implementation :: CPython",
    ],
)