
SRC_FILES=$(find -iname "*.vala")
VAPI_FILES=/usr/share/vala-0.28/vapi/xcb.vapi
CFLAGS=-lxcb
VFLAGS=--thread
PKGS=--pkg gee-0.8

OUTPUT_DIR=./build
OUTPUT_FILE=kraken

all:
	valac $(VFLAGS) $(SRC_FILES) $(VAPI_FILES) -X $(CFLAGS) -o $(OUTPUT_DIR)/$(OUTPUT_FILE)

run:
	$(OUTPUT_DIR)/$(OUTPUT_FILE)

clean:
	rm -f $(OUTPUT_DIR)/$(OUTPUT_FILE)
