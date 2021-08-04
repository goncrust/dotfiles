FRAMEWORK_PATH = -F/System/Library/PrivateFrameworks
FRAMEWORK      = -framework Carbon -framework Cocoa -framework CoreServices -framework SkyLight
BUILD_FLAGS    = -std=c99 -Wall -DNDEBUG -O2 -fvisibility=hidden -mmacosx-version-min=10.13
BUILD_PATH     = ./bin
DOC_PATH       = ./doc
SRC            = ./src/manifest.m
BINS           = $(BUILD_PATH)/limelight

.PHONY: all clean sign man

all: clean $(BINS)

man:
	asciidoctor -b manpage $(DOC_PATH)/limelight.asciidoc -o $(DOC_PATH)/limelight.1

sign:
	codesign -fs "yabai-cert" $(BUILD_PATH)/limelight

clean:
	rm -rf $(BUILD_PATH)

$(BUILD_PATH)/limelight: $(SRC)
	mkdir -p $(BUILD_PATH)
	clang $^ $(BUILD_FLAGS) $(FRAMEWORK_PATH) $(FRAMEWORK) -o $@
