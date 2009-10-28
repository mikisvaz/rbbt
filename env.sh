#!/bin/bash

### SETS A NUMBER OF VARIABLES

export RBBT_HOME=$PWD

export RUBYOPT="$RUBYOPT -I$RBBT_HOME/lib "

# Needed for R. R needs decimal points as periods
export LC_NUMERIC=C

