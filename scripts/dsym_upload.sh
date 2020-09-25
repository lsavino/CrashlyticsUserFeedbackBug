#!/usr/bin/env bash

DSYM_FILE_PATH="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"

echo "dSYM File Path:"
echo ${DSYM_FILE_PATH}

DIR_SCRIPT="$(dirname $0)"

echo "dir script:"
echo ${DIR_SCRIPT}

UPLOAD_ARGS="-gsp ${BUILT_PRODUCTS_DIR}/GoogleService-Info.plist -p ios ${DSYM_FILE_PATH}"

echo "upload args:"
echo ${UPLOAD_ARGS}

exit 0



# ~/Downloads/Firebase/FirebaseCrashlytics/upload-symbols -gsp ~/code/finding\ things/CrashReportAugmentBug/CrashReportAugmentBug/GoogleService-Info.plist -p ios /Users/laurasavino/Library/Developer/Xcode/DerivedData/CrashReportAugmentBug-btacclqvtuiuohfbtxcazwjstqjl/Build/Products

