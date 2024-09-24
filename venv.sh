#!/bin/bash

BIN_DIR=$(dirname $0)
cd $BIN_DIR

PYTHON='python3'

$PYTHON -m venv .venv

source .venv/bin/activate

pip install -r requirements.txt