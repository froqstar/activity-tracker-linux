
SRC_FILES=$(shell find -iname "*.vala")
VAPI_FILES=/usr/share/vala-0.28/vapi/xcb.vapi
CFLAGS=-lxcb
VFLAGS=--thread
PKGS=--pkg gee-0.8 --pkg gio-2.0 --pkg json-glib-1.0 --pkg dbus-glib-1

OUTPUT_DIR=./build
OUTPUT_FILE=kraken.bin

all:
	valac $(VFLAGS) $(PKGS) $(SRC_FILES) $(VAPI_FILES) -X $(CFLAGS) -o $(OUTPUT_DIR)/$(OUTPUT_FILE)

run: all
	$(OUTPUT_DIR)/$(OUTPUT_FILE)

clean:
	rm -f $(OUTPUT_DIR)/$(OUTPUT_FILE)
