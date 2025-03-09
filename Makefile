DERIVED_DATA_PATH = ~/.derivedData/$(CONFIG)

PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iOS,iPhone \d\+ Pro [^M])
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,id=$(call udid_for,tvOS,TV)
PLATFORM_VISIONOS = visionOS Simulator,id=$(call udid_for,visionOS,Vision)
PLATFORM_WATCHOS = watchOS Simulator,id=$(call udid_for,watchOS,Watch)

ifeq ($(PLATFORM),iOS)
	DESTINATION = "$(PLATFORM_IOS)"
else ifeq ($(PLATFORM),macOS)
	DESTINATION = "$(PLATFORM_MACOS)"
else ifeq ($(PLATFORM),tvOS)
	DESTINATION = "$(PLATFORM_TVOS)"
else ifeq ($(PLATFORM),watchOS)
	DESTINATION = "$(PLATFORM_WATCHOS)"
else ifeq ($(PLATFORM),visionOS)
	DESTINATION = "$(PLATFORM_VISIONOS)"
else ifeq ($(PLATFORM),macCatalyst)
	DESTINATION = "$(PLATFORM_MAC_CATALYST)"
else
	DESTINATION = __unsupported__
endif

PLATFORM_ID = $(shell echo "$(DESTINATION)" | sed -E "s/.+,id=(.+)/\1/")

SCHEME = Unspecified
WORKSPACE = ".swiftpm/xcode/package.xcworkspace"

ifeq ($(BEAUTIFY),true)
	XCBEAUTIFY = xcbeautify
	XCBEAUTIFY_COMMAND = xcbeautify
else ifeq ($(BEAUTIFY),quiet)
	XCBEAUTIFY = xcbeautify
	XCBEAUTIFY_COMMAND = xcbeautify --quiet
else
	XCBEAUTIFY = __do_not_beautify__
endif

XCODEBUILD_FLAGS = \
	-configuration $(CONFIG) \
	-derivedDataPath $(DERIVED_DATA_PATH) \
	-destination=$(DESTINATION) \
	-scheme "$(SCHEME)" \
	-skipMacroValidation \
	-workspace $(WORKSPACE)

XCODEBUILD_COMMAND = xcodebuild $(COMMAND) $(XCODEBUILD_FLAGS)

ifneq ($(strip $(shell which $(XCBEAUTIFY))),)
	XCODEBUILD = set -o pipefail && $(XCODEBUILD_COMMAND) | $(XCBEAUTIFY_COMMAND)
else
	XCODEBUILD = $(XCODEBUILD_COMMAND)
endif

TEST_RUNNER_CI = $(CI)

warm-simulator:
	@echo "Running warm-simulator for $(PLATFORM)"
	@test "$(PLATFORM_ID)" != "" \
		&& xcrun simctl boot $(PLATFORM_ID) \
		&& open -a Simulator --args -CurrentDeviceUDID $(PLATFORM_ID) \
		|| exit 0

xcodebuild: warm-simulator
	@echo "Running xcodebuild for $(PLATFORM)"
	@echo "  Workspace: $(WORKSPACE)"
	@echo "  Scheme: $(SCHEME)"
	@echo "  Config: $(CONFIG)"
	@echo "  Destination: $(DESTINATION)"
	@echo "  DerivedData: $(DERIVED_DATA_PATH)"
	$(XCODEBUILD)

# Workaround for debugging Swift Testing tests: https://github.com/cpisciotta/xcbeautify/issues/313
xcodebuild-raw: warm-simulator
	@echo "Running xcodebuild-raw for $(PLATFORM)"
	@echo "  Workspace: $(WORKSPACE)"
	@echo "  Scheme: $(SCHEME)"
	@echo "  Config: $(CONFIG)"
	@echo "  Destination: $(DESTINATION)"
	@echo "  DerivedData: $(DERIVED_DATA_PATH)"
	$(XCODEBUILD_COMMAND)

build-for-library-evolution:
	@echo "Running build-for-library-evolution for $(SCHEME)"
	swift build \
		-q \
		-c release \
		--target ${SCHEME} \
		-Xswiftc -emit-module-interface \
		-Xswiftc -enable-library-evolution

benchmark:
	@echo "Running benchmark for $(SCHEME)"
	swift run --configuration release $(SCHEME)

swift-format:
	@echo "Running swift-format"
	find . \
		-path '*/Documentation.docc' -prune -o \
		-name '*.swift' \
		-not -path '*/.*' -print0 \
		| xargs -0 swift format --ignore-unparsable-files --in-place

DOC_WARNINGS = $(shell \
	xcodebuild clean docbuild \
		-scheme "$(SCHEME)" \
		-destination platform="$(DESTINATION)" \
		-quiet 2>&1 \
		| grep "couldn't be resolved to known documentation" \
		| sed 's|$(PWD)|.|g' \
		| tr '\n' '\1' \
)

test-docs:
	@echo "Running test-docs for $(SCHEME) [$(PLATFORM)]"
	@test "$(DOC_WARNINGS)" = "" \
		|| (echo "xcodebuild docbuild failed:\n\n$(DOC_WARNINGS)" | tr '\1' '\n' \
		&& exit 1)

github-build-docs:
	@echo "Running github-build-docs for $(SCHEME)"
	@chmod +x '.scripts/github-build-docs'
	SCHEME=$(SCHEME) ./.scripts/github-build-docs

.PHONY: build-for-library-evolution format warm-simulator xcodebuild xcodebuild-raw test-docs

define udid_for
$(shell \
	xcrun simctl list devices available '$(1)' \
	| grep '$(2)' \
	| sort -r \
	| head -1 \
	| awk -F '[()]' '{ print $$(NF-3) }' \
)
endef

# simple action for testing if Makefile is valid
ping:
	@echo "pong 🏓"
