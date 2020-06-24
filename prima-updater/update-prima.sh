#!/bin/bash

curr_dir=${PWD##*/}
if [ $curr_dir == "prima-updater" ]; then
    echo "> You're calling this script from the wrong scope, moving one up..."
    cd ..
fi
echo "> Fetching Latest CAF Releases..."

# TAG PREFIX LA.UM.8.6.r1
STAGING_PATH="drivers/staging"
PRIMA_PATH="$STAGING_PATH/prima"
PRIMA_LATEST_PATH="$STAGING_PATH/prima-latest"
QCOM_TAG_REGEX="LA\.UM\.8\.6\.r1-\d+-89xx\.0"
QCOM_RELEASE_URL="https://wiki.codeaurora.org/xwiki/bin/QAEP/release"
QCOM_LATEST_TAG=$(curl -v --stderr - ${QCOM_RELEASE_URL} | grep -oP "${QCOM_TAG_REGEX}" | head -n1)
QCOM_PRIMA_URL="https://source.codeaurora.org/quic/la/platform/vendor/qcom-opensource/wlan/prima/"

echo "> Latest TAG: $QCOM_LATEST_TAG"

# Download the latest caf tag compatible for our device.
git clone $QCOM_PRIMA_URL -b $QCOM_LATEST_TAG $PRIMA_LATEST_PATH --depth=1

# Remove .git folder
echo "> Deleting $PRIMA_LATEST_PATH/.git"
rm -rf $PRIMA_LATEST_PATH/.git

# Applying patches
echo "> Applying patches..."
for i in prima-updater/patches/*.patch; do patch -p1 < $i; done

# Moving to the expected folder
echo "> Deleting old prima folder..."
rm -rf $PRIMA_PATH
echo "> Moving $PRIMA_LATEST_PATH to $PRIMA_PATH..."
mv $PRIMA_LATEST_PATH $PRIMA_PATH

# Commit please =)
echo "> Creating commit..."
git add $PRIMA_PATH
git commit -m ":zap: Prima updated to $QCOM_LATEST_TAG"
echo "> Done!. Now push those changes =)"
