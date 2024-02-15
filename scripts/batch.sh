#!/usr/bin/env bash
# Copyright (c) 2024, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.

set -e

# Source the JARVICE job environment variables
[[ -r /etc/JARVICE/jobenv.sh ]] && source /etc/JARVICE/jobenv.sh
[[ -r /etc/JARVICE/jobinfo.sh ]] && source /etc/JARVICE/jobinfo.sh

# Get the input file
INPUT_FILE=""
while [ -n "$1" ]; do
  case "$1" in
  -i)
    shift
    INPUT_FILE="$1"
    ;;
  *) ;;
  esac
  shift
done

# Change to the working directory
WORK_DIRECTORY=$(dirname "$INPUT_FILE")
echo "INFO: Changing to work directory: $WORK_DIRECTORY"
cd $WORK_DIRECTORY

# Source convergence environment
. /opt/converge/env.sh

# Get MPI Options (ONLY IB right now)
MPIOPTS="--mca io ompio --mca fs_ufs_lock_algorithm 3"
MPIOPTS="$MPIOPTS -x LD_LIBRARY_PATH"
MPIOPTS="$MPIOPTS -x PATH"
MPIOPTS="$MPIOPTS --hostfile /etc/JARVICE/nodes"
MPIOPTS="$MPIOPTS --map-by core"
MPIOPTS="$MPIOPTS --bind-to core"

CORES=$(wc -l /etc/JARVICE/cores | awk '{print $1}')
MPIOPTS="$MPIOPTS -np $CORES"

if [ "$JARVICE_MPI_PROVIDER" == "efa" ]; then
 echo "INFO: Enabling EFA"
 MPIOPTS="$MPIOPTS --mca pml ^ucx --mca mtl ofi"
fi

if [ "$JARVICE_MPI_PROVIDER" = "verbs" ]; then
  echo "INFO: Enabling Infiniband"
  if [ -n "$(find /opt/ -name ucx_info | head -n1)" ]; then
    MPIOPTS="$MPIOPTS --mca btl ^openib --mca pml ucx"
  else
    MPIOPTS="$MPIOPTS --mca btl openib,vader,self --mca btl_openib_allow_ib true"
  fi
fi

cmd="$(which mpirun) $MPIOPTS /opt/converge/bin/converge super"
echo "Running: $cmd"
eval $cmd
EXIT_CODE=$?

# tail the log file to screen to get the breakdown of times
if [[ ! -f ./converge.log ]]; then
  exit $EXIT_CODE
fi

TOT_LINES=$(wc -l < ./converge.log)
LINE_START=$(grep -n -- "Total Simulation Run Time:" ./converge.log | cut -f1 -d:)
if [[ -z $LINE_START ]]; then
  exit $EXIT_CODE
fi
TAIL_N=$((TOT_LINES-LINE_START+1))
tail -n $TAIL_N ./converge.log

# Return the exit code from the program
exit $EXIT_CODE
