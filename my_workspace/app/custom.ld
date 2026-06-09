/* Intended linker snippet */
SECTION_PROLOGUE(.placeholder_section,,) {
    KEEP(*(.placeholder_section))
} GROUP_LINK_IN(RAMABLE_REGION)
