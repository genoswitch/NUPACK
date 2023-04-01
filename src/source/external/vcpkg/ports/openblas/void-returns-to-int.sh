#!/bin/sh

# Source:
# pyodide/pyodide#3331 "Attempt to package OpenBLAS and use OpenBLAS in scipy"
# https://github.com/pyodide/pyodide/blob/1e1e4c2048218e671dfe159bd38ea9ba3058e597/packages/openblas/meta.yaml

# Replace void returns by int returns
sed -ri 's/void(\s+)BLASFUNC/int\1BLASFUNC/g' common_interface.h
sed -ri 's/void(\s+)cblas_/int\1cblas_/g' cblas.h ctest/*.c
sed -ri 's/void(\s+)(C?NAME)/int\1\2/g' interface/*.c