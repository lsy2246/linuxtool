#!/bin/bash
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装"
    exit 1
fi
