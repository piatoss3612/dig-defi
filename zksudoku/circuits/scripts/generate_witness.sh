#!/bin/bash

# Variable to store the name of the circuit
CIRCUIT=sudoku

# Path to the directory where the circuit is located
PATH_CIRCUIT=./${CIRCUIT}

# In case there is a circuit name as input
if [ "$1" ]; then
    CIRCUIT=$1
fi
# Build directory path
BUILD_DIR=build/${CIRCUIT}

# Generate the witness.wtns
node ${BUILD_DIR}/${CIRCUIT}_js/generate_witness.js ${BUILD_DIR}/${CIRCUIT}_js/${CIRCUIT}.wasm ${PATH_CIRCUIT}/input.json ${BUILD_DIR}/${CIRCUIT}_js/witness.wtns