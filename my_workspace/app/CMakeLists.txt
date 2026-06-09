cmake_minimum_required(VERSION 3.30.0)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(test_zephyr_linker_search_bug)

target_sources(app PRIVATE src/main.c)

# Register custom linker script
zephyr_linker_sources(DATA_SECTIONS custom.ld)
