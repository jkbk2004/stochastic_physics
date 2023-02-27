#!/bin/bash
compile_all=1
DEBUG=1

#rm standalone_stochy.x
export ESMFMKFILE=${ESMFMKFILE:-/home/builder/opt/lib/esmf.mk}
export PATH=/home/builder/opt/bin:$PATH
export LD_LIBRARY_PATH=/home/builder/opt/lib
export LD_LIBRARY_PATH=/home/builder/opt/lib64
export CMAKE_PREFIX_PATH=/home/builder/opt
export FC=mpifort
export CC=mpicc
export CXX=mpicxx
/bin/bash ufs_linux.gnu
export FMS_ROOT=/home/builder/opt
export NETCDF=/home/builder/opt
echo ${FMS_ROOT}
#FC=mpif90
#FMS_INC=${FMS_ROOT}/include_r4
#FMS_LIB=${FMS_ROOT}/lib
#INCS="-I. -I${FMS_INC} -I${NETCDF}/include"
if [ $DEBUG -eq 1 ]; then
   FLAGS="-DDEBUG -ggdb -fbacktrace -cpp -fcray-pointer -ffree-line-length-none -fno-range-check -fdefault-real-8 -fdefault-double-8 -g -O0 -fno-unsafe-math-optimizations -frounding-math -fsignaling-nans -ffpe-trap=invalid,zero,overflow -fbounds-check -I. -fopenmp -c -Wargument-mismatch "$INCS
else
   FLAGS="-ggdb -fbacktrace -cpp -fcray-pointer -ffree-line-length-none -fno-range-check -O2 -fdefault-real-8 -O2 -fPIC -fopenmp -c -Wargument-mismatch "$INCS
fi
cd ..
if [ $compile_all -eq 1 ];then
   rm -f *.i90 *.i *.o *.mod lib*a
   $FC ${FLAGS} kinddef.F90
   $FC ${FLAGS} mpi_wrapper.F90
   $FC ${FLAGS} unit_tests/fv_arrays_stub.F90
   $FC ${FLAGS} unit_tests/fv_mp_stub_mod.F90
   $FC ${FLAGS} unit_tests/fv_control_stub.F90
   $FC ${FLAGS} unit_tests/atmosphere_stub.F90
   $FC ${FLAGS} mersenne_twister.F90
   $FC ${FLAGS} stochy_internal_state_mod.F90
   $FC ${FLAGS} stochy_namelist_def.F90
   $FC ${FLAGS} spectral_transforms.F90
   $FC ${FLAGS} compns_stochy.F90
   $FC ${FLAGS} stochy_patterngenerator.F90
   $FC ${FLAGS} stochy_data_mod.F90
   $FC ${FLAGS} get_stochy_pattern.F90
   $FC ${FLAGS} lndp_apply_perts.F90
   $FC ${FLAGS} stochastic_physics.F90
fi
ar rv libstochastic_physics.a *.o
if [ $DEBUG -eq 1 ]; then
   $FC -fdec -ggdb -fbacktrace -cpp -fcray-pointer -ffree-line-length-none -fno-range-check -fdefault-real-8 -fdefault-double-8 -g -O0 -fno-unsafe-math-optimizations -frounding-math -fsignaling-nans -ffpe-trap=invalid,zero,overflow -fbounds-check -I. -fopenmp -o unit_tests/standalone_stochy.x unit_tests/standalone_stochy.F90 ${INCS} -I${NETCDF}/include -L. -lstochastic_physics -L${FMS_LIB} -lfms_r4 -L${ESMF_LIB} -Wl,-rpath,${ESMF_LIB} -lesmf -L${NETCDF}/lib -lnetcdff -lnetcdf -L${HDF5_LIBRARIES} -lhdf5_hl -lhdf5 \
-L${ZLIB_LIBRARIES} -lz -ldl
else
   $FC -fdec -fbacktrace -cpp -fcray-pointer -ffree-line-length-none -fno-range-check -fdefault-real-8 -fdefault-double-8 -g -O2 -I. -fopenmp -o unit_tests/standalone_stochy.x unit_tests/standalone_stochy.F90 ${INCS} -I${NETCDF}/include -L. -lstochastic_physics -L${FMS_LIB} -lfms_r4 -L${ESMF_LIB} -Wl,-rpath,${ESMF_LIB} -lesmf -L${NETCDF}/lib -lnetcdff -lnetcdf -L${HDF5_LIBRARIES} -lhdf5_hl -lhdf5 \
-L${ZLIB_LIBRARIES} -lz -ldl
fi
