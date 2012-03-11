# Run the unit tests in this test bundle.
"${SYSTEM_DEVELOPER_DIR}/Tools/RunUnitTests"

exit 0

# Short circuit if the library hasn't changed.
if [[ ! "${CONFIGURATION_BUILD_DIR}/${NIMBUS_TARGET_NAME}Tests.octest/${NIMBUS_TARGET_NAME}Tests" -nt "${PROJECT_DIR}/../coverage/${NIMBUS_FEATURE_NAME}/index.html" ]]
then
    exit 0
fi

mkdir -p "${PROJECT_DIR}/../coverage"
rm -rf "${PROJECT_DIR}/../coverage/${NIMBUS_FEATURE_NAME}"
osascript ../scripts/generate_coverage.applescript "${CONFIGURATION_TEMP_DIR}/${NIMBUS_TARGET_NAME}.build/" "${PROJECT_DIR}/../coverage/${NIMBUS_FEATURE_NAME}"
