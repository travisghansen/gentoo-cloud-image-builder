#!/bin/bash

echo "creating builder iso"
mkisofs --input-charset utf-8 -J -r -V builder -o iso/builder.iso builder 2> /dev/null

echo "creating config iso"
mkisofs --input-charset utf-8 -J -r -V config-2 -o iso/config.iso metadata 2> /dev/null
