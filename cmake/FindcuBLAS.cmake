#==========================================================================
#  Copyright (C) Codeplay Software Limited
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  For your convenience, a copy of the License has been included in this
#  repository.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#=========================================================================

find_package(CUDA 10.0 REQUIRED)
enable_language(CUDA)
find_path(CUBLAS_INCLUDE_DIR "cublas_v2.h" HINTS ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})
get_filename_component(SYCL_BINARY_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
# the OpenCL include file from cuda is opencl 1.1 and it is not compatible with DPC++
# the OpenCL include headers 1.2 onward is required. This is used to bypass NVIDIA OpenCL headers
find_path(OPENCL_INCLUDE_DIR CL/cl.h OpenCL/cl.h 
HINTS 
${OPENCL_INCLUDE_DIR}
${SYCL_BINARY_DIR}/../include/sycl/
)
find_library(CUBLAS_LIBRARY cublas)
find_library(CUDA_DRIVER_LIBRARY cuda)
# this is work around to avoid duplication half creation in both cuda and SYCL
add_compile_definitions(CUDA_NO_HALF)

find_package(Threads REQUIRED)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(cuBLAS
    REQUIRED_VARS
        CUBLAS_INCLUDE_DIR
        CUDA_INCLUDE_DIRS
        CUBLAS_LIBRARY
        CUDA_LIBRARIES
        CUDA_DRIVER_LIBRARY
        OPENCL_INCLUDE_DIR
)
if(NOT TARGET ONEMKL::cuBLAS::cuBLAS)
  add_library(ONEMKL::cuBLAS::cuBLAS SHARED IMPORTED)
  set_target_properties(ONEMKL::cuBLAS::cuBLAS PROPERTIES
      IMPORTED_LOCATION ${CUBLAS_LIBRARY}
      INTERFACE_INCLUDE_DIRECTORIES "${OPENCL_INCLUDE_DIR};${CUDA_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "Threads::Threads;${CUDA_DRIVER_LIBRARY};${CUDA_LIBRARIES}"
  )

endif()
