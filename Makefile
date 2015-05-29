
SRC_FILES=$(find -iname "*.vala")
VAPI_FILES=/usr/share/vala-0.28/vapi/xcb.vapi
CFLAGS=-lxcb
VFLAGS=--thread

OUTPUT_DIR=./build
OUTPUT_FILE=kraken

all:
	valac $(VFLAGS) $(SRC_FILES) $(VAPI_FILES) -X $(CFLAGS) -o $(OUTPUT_DIR)/$(OUTPUT_FILE)
	$(OUTPUT_DIR)/$(OUTPUT_FILE)

clean:
	rm -f 
