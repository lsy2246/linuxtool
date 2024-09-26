#!/bin/bash
if ! command -v ssh &> /dev/null; then
    echo "ssh未安装"
    exit
fi
