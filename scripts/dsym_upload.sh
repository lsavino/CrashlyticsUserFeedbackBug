#!/usr/bin/env bash

DSYM_FILE_PATH="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"

echo "dSYM File Path:"
echo ${DSYM_FILE_PATH}

UPLOAD_SYMBOLS_EXE="'${PROJECT_DIR}'/scripts/upload-symbols"

echo "upload executable:"
echo ${UPLOAD_SYMBOLS_EXE}

UPLOAD_ARGS="-gsp '${PROJECT_DIR}'/'${PRODUCT_NAME}'/GoogleService-Info.plist -p ios '${DSYM_FILE_PATH}'"

echo "upload args:"
echo ${UPLOAD_ARGS}

eval "${UPLOAD_SYMBOLS_EXE}" "${UPLOAD_ARGS}"
RETURN_CODE=$?

exit $RETURN_CODE
