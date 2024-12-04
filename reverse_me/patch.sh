#!/bin/bash

BINDIR="binary"
OUTDIR="patched"

BIN1="level1"
BIN2="level2"
BIN3="level3"

declare -A BIN_PATCHES=(
 ["$BIN1"]="0x1244 0f8516000000 909090909090"
 ["$BIN2"]="0x131e 0f8408000000 90e908000000
			0x1337 0f8408000000 90e908000000
			0x1350 0f8408000000 90e908000000
			0x146d 0f850d000000 909090909090"
 ["$BIN3"]="0x135a 0f8405000000 90e931000000
			0x1486 0f84aa000000 90e917000000
			0x14a7 0f84b1000000 90e9b1000000"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

check_elf_type() {
	local binary="$1"
	file "$binary" | grep -q "64-bit" && echo "64" || echo "32"
}

print_header() {
	echo -e "${CYAN}${BOLD}$1${NC}"
}

print_success() {
	echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
	echo -e "${RED}✗ $1${NC}"
}

print_info() {
	echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
	echo -e "${YELLOW}⚠ $1${NC}"
}

patch_binary() {
	local binary="$1"
	local patches="$2"
	local input_file="$BINDIR/$binary"
	local output_file="$OUTDIR/$binary"

	print_header "╔════════════════════════════════════════"
	print_header "║ Patching binary: $binary"
	print_header "╚════════════════════════════════════════"
	
	if [ ! -f "$input_file" ]; then
		print_error "Input file $input_file does not exist"
		return 1
	fi

	mkdir -p "$OUTDIR"
	cp "$input_file" "$output_file"
	chmod u+w "$output_file"

	local bits=$(check_elf_type "$input_file")
	print_info "Detected ${bits}-bit ELF binary"

	while read -r PATCH; do
		[[ -z "$PATCH" ]] && continue
		OFFSET=$(echo "$PATCH" | awk '{print $1}')
		ORIGINAL=$(echo "$PATCH" | awk '{print $2}')
		REPLACEMENT=$(echo "$PATCH" | awk '{print $3}')
		OFFSET_DEC=$((OFFSET))
		ORIG_LEN=$((${#ORIGINAL} / 2))
		CURRENT_BYTES=$(xxd -s "$OFFSET_DEC" -l "$ORIG_LEN" -p "$output_file")

		CURRENT_BYTES=$(echo "$CURRENT_BYTES" | tr '[:upper:]' '[:lower:]')
		ORIGINAL=$(echo "$ORIGINAL" | tr '[:upper:]' '[:lower:]')

		if [[ "$CURRENT_BYTES" != "$ORIGINAL" ]]; then
			print_error "Mismatch at offset $OFFSET in $binary"
			echo -e "${MAGENTA}Found:    ${RED}$CURRENT_BYTES"
			echo -e "${MAGENTA}Expected: ${GREEN}$ORIGINAL${NC}"
			continue
		fi

		echo -ne "$(echo "$REPLACEMENT" | xxd -r -p)" | \
			dd of="$output_file" bs=1 seek="$OFFSET_DEC" conv=notrunc status=none

		print_success "Patched offset ${CYAN}$OFFSET${NC}: ${YELLOW}$ORIGINAL${NC} -> ${GREEN}$REPLACEMENT${NC}"
	done <<< "$patches"

	chmod +x "$output_file"
	print_success "Successfully patched $binary"
	echo
}

print_header "══════════════════════════════════════════════════════════════════════════════════════════"
print_header "      :::::::::: :::::::::::           :::::::::     ::: ::::::::::: ::::::::  :::    ::: "
print_header "     :+:            :+:               :+:    :+:  :+: :+:   :+:    :+:    :+: :+:    :+:  "
print_header "    +:+            +:+               +:+    +:+ +:+   +:+  +:+    +:+        +:+    +:+   "
print_header "   :#::+::#       +#+               +#++:++#+ +#++:++#++: +#+    +#+        +#++:++#++    "
print_header "  +#+            +#+               +#+       +#+     +#+ +#+    +#+        +#+    +#+     "
print_header " #+#            #+#               #+#       #+#     #+# #+#    #+#    #+# #+#    #+#      "
print_header "###            ###    ########## ###       ###     ### ###     ########  ###    ###       "
print_header "╔═════════════════════════════════════════════════════════════════════════════════════════"
print_header "║ Binary Patching Tool"
print_header "╚════════════════════════════════════════"
echo

for BINARY in "${!BIN_PATCHES[@]}"; do
	patch_binary "$BINARY" "${BIN_PATCHES[$BINARY]}"
done

print_success "All binaries have been patched and saved to $OUTDIR"
