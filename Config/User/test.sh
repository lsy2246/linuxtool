#!/bin/bash
if ! command -v ssh &> /dev/null; then
    echo "SSH 客户端未安装"
    exit
fi
