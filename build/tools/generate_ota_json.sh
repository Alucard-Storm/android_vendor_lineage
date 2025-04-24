#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <TARGET_DEVICE> <PRODUCT_OUT> <FILENAME>"
    exit 1
fi

TARGET_DEVICE=$1
PRODUCT_OUT=$2
HORIZON_ZIP=$3
FILENAME="$HORIZON_ZIP"

if [[ "$FILENAME" =~ HorizonDroid-.*-(OFFICIAL|UNOFFICIAL)-[0-9]+\.zip ]]; then
    ROMTYPE="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract ROM type from filename: $FILENAME"
    exit 1
fi

if [[ "$FILENAME" =~ HorizonDroid-([a-z0-9\.]+)-.*\.zip ]]; then
    VERSION="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract version from filename: $FILENAME"
    exit 1
fi

if [[ "$FILENAME" =~ HorizonDroid-.*-(GAPPS|VANILLA)-.*\.zip ]]; then
    FLAVOR="${BASH_REMATCH[1]}"
else
    echo "Error: Unable to extract build flavor from filename: $FILENAME"
    exit 1
fi

FILE_PATH="$PRODUCT_OUT/$FILENAME"

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

SIZE=$(stat -c%s "$FILE_PATH")
ID=$(md5sum "$FILE_PATH" | awk '{print $1}')
DATETIME=$(date +%s)

JSON_DIR="$PRODUCT_OUT/$FLAVOR"
if [ ! -d "$JSON_DIR" ]; then
    mkdir -p "$JSON_DIR"
fi
JSON_FILE="$JSON_DIR/${TARGET_DEVICE}.json"

cat > "$JSON_FILE" <<EOF
{
    "response": [
        {
            "datetime": $DATETIME,
            "filename": "$FILENAME",
            "id": "$ID",
            "romtype": "$ROMTYPE",
            "size": $SIZE,
            "url": "",
            "version": "$VERSION"
        }
    ]
}
EOF

echo "JSON saved to: $JSON_FILE"

exit 0
