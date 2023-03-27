vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Gecode/gecode
    REF fec7e9fd99bca98f146416ba8ea8adc278f5a95a
    SHA512 414e1a8ddaaea65fcc758c78a4e8a78553472fd8386d1a2fb40b0a001878debd21e5b7f73ddd2876c900df5554d4d187f7c2df7b3249956b305e723dd7bca632
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    # OPTIONS
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
