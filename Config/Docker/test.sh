#!/bin/bash
if ! command -v docker &> /dev/null; then
    echo "docker未安装"
    exit 1
fi
