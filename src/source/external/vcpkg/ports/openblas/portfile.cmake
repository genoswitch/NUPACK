vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xianyi/OpenBLAS
    REF e46971b9d572a6cf040179b1d67e8408ce944a6f # v0.3.22
    SHA512 2772afe2b73fe2b38bedc504b721d496b2303cc9159739e12129b38692836b8058bebc62699d3e1a36b90ef06d0919ed1cb9a0bf7349c2ef6f9958e47397890f
    HEAD_REF develop
)

foreach(BUILDTYPE "debug" "release")
    if(BUILDTYPE STREQUAL "debug")
        set(SHORT_BUILDTYPE "-dbg")
        set(CMAKE_BUILDTYPE "DEBUG")
        set(PATH_SUFFIX "/debug")
    else()
        if (_VCPKG_NO_DEBUG)
            set(SHORT_BUILDTYPE "")
        else()
            set(SHORT_BUILDTYPE "-rel")
        endif()
        set(CMAKE_BUILDTYPE "RELEASE")
        set(PATH_SUFFIX "")
     endif()

    set(WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${SHORT_BUILDTYPE}")

    if (NOT EXISTS "${WORKING_DIRECTORY}")
        file(MAKE_DIRECTORY "${WORKING_DIRECTORY}")
    endif()

    message(STATUS "Sourcepath: ${SOURCE_PATH}")
    message(STATUS "Destination: ${WORKING_DIRECTORY}")

    file(COPY ${SOURCE_PATH}/ DESTINATION ${WORKING_DIRECTORY})
endforeach()

# NOTE: This appears to only build the release build type.
vcpkg_execute_build_process(
    COMMAND emmake make libs shared CC=emcc HOSTCC=gcc TARGET=RISCV64_GENERIC NOFORTRAN=1 USE_THREAD=0 -j${VCPKG_CONCURRENCY}
    WORKING_DIRECTORY ${WORKING_DIRECTORY}
    LOGNAME manual-${TARGET_TRIPLET}
)


file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)

file(GLOB DYN_LIBS ${WORKING_DIRECTORY}/*.so*) # .so.0 for example
file(GLOB STATIC_LIBS ${WORKING_DIRECTORY}/*.a)
file(INSTALL ${DYN_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${STATIC_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

# openblas do not make the config file , so I manually made this
# but I think in most case, libraries will not include these files, they define their own used function prototypes
# this is only to quite vcpkg
file(COPY ${CMAKE_CURRENT_LIST_DIR}/openblas_common.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(READ ${SOURCE_PATH}/cblas.h CBLAS_H)
string(REPLACE "#include \"common.h\"" "#include \"openblas_common.h\"" CBLAS_H "${CBLAS_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/cblas.h "${CBLAS_H}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
