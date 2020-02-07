#!/bin/bash

# Greetings.
printf "\n"
echo "################################################"
echo "#                                              #"
echo "#   Drag and drop available for files/paths.   #"
echo "#                                              #"
echo "################################################"
printf "\n\n"

# Fake loading
printf "\e[32mChecking paths...\e[0m\n"
sleep 1

# Define unsigned apk file
export UNSIGNED_APK="$(pwd)/platforms/android/app/build/outputs/apk/release/app-release-unsigned.apk"

# Get keystore file
read -p "Keystore name/path [eg. ./app.keystore]: " KEYSTORE_NAME

# check keystore_name until it's existst and a real keystore file
while [[ ! -f $KEYSTORE_NAME  ]] || [[ $KEYSTORE_NAME != *".keystore"* ]]; do
    printf "\e[91mKeystore file \"$KEYSTORE_NAME\" not found or not a keystore.\nPlease provide a keystore path...\e[0m\n"
    read -p 'Give full path of the keystore or drop the file into the terminal: ' KEYSTORE_NAME
done

# Get other things
read -sp "Store password: " STORE_PASSWORD
printf "\n"
read -p "Keystore alias [app]: " KEYSTORE_ALIAS
read -sp "Password: " PASSWORD
printf "\n"

# Create final apk filename
export FINAL_APK_NAME="$KEYSTORE_ALIAS-final.apk"

# Build app
cordova build android -release -keystore=$KEYSTORE_NAME -storePassword=$STORE_PASSWORD -alias=$KEYSTORE_ALIAS -password=$PASSWORD

# Check unsigned_apk until it's exists and a real apk file
while [[ ! -f $UNSIGNED_APK  ]] || [[ $UNSIGNED_APK != *".apk"* ]]; do
    printf "\e[91mRelease APK file \"$UNSIGNED_APK\" not found or not an apk file.\nPlease provide a release apk path...\e[0m\n"
    read -p 'Give full path of the release apk or drop apk file into the terminal: ' UNSIGNED_APK
done

# Sign apk file
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KEYSTORE_NAME $UNSIGNED_APK $KEYSTORE_ALIAS

# Check if final_apk file exists and delete
if [ -f $FINAL_APK_NAME ]; then
    echo "File $FINAL_APK_NAME exists. Deleting..."
    rm -rf $FINAL_APK_NAME
fi

sleep 2

# Align new apk file
zipalign -v 4 $UNSIGNED_APK $FINAL_APK_NAME

clear

printf "\n\e[32mNew apk file \"\e[5m$FINAL_APK_NAME\e[0m\e[32m\" created in \"$(pwd)\".\e[0m \n"
