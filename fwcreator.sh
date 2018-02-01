#!/bin/bash

if [ -z $1 ]; then
    echo "Usage: fwcreator.sh MIUI_FULL_ZIP_FILE"
    exit 1
fi

if [ ! -f $1 ]; then
    echo "** File not available."
    exit 1
fi

function creatupscrpt() {
    echo "$(cat $1 | awk '/getprop/ && /ro.product.device/')" > $2
    echo "$(cat $1 | awk '/ui_print/ && /Target:/')" >> $2
    echo "show_progress(0.200000, 10);" >> $2
    echo 'ui_print("Patching firmware images...");' >> $2
    echo "$(cat $1 | awk '/package_extract_file/ && /firmware-update\//')" >> $2
    echo "show_progress(0.100000, 2);" >> $2
    echo "set_progress(1.000000);" >> $2
}

mkdir temp/
mkdir temp/unzipped
unzip $1 -d temp/unzipped/

if [ ! -f temp/unzipped/META-INF/com/google/android/update-binary ] || [ ! -f temp/unzipped/META-INF/com/google/android/updater-script ] || [ ! -d temp/unzipped/firmware-update ]; then
    echo "** This zip doesn't contain firmware directory."
    rm -rf temp/
    exit 1
fi

mv temp/unzipped/firmware-update temp/

mkdir -p temp/META-INF/com/google/android
mv temp/unzipped/META-INF/com/google/android/update-binary temp/META-INF/com/google/android/
creatupscrpt temp/unzipped/META-INF/com/google/android/updater-script temp/META-INF/com/google/android/updater-script

cd temp/
zip -r ../Base_firmware.zip META-INF/ firmware-update/
cd ../

rm -rf temp/
