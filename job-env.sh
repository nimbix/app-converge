#!/bin/bash

# Jarvice
if [ -d /etc/JARVICE ]; then
  if [ -f /etc/JARVICE/cores ] && [ -z "${J_NBCORES}" ]; then
    export J_NBCORES=`wc -l /etc/JARVICE/cores | awk '{print $1}'`
  fi
  if [ -f /etc/JARVICE/nodes ] && [ -z "${J_NBNODES}" ]; then
    export J_NBNODES=`wc -l /etc/JARVICE/nodes | awk '{print $1}'`
  fi
  if [ -f /etc/JARVICE/nodes ] && [ -z "${J_HOSTFILE}" ]; then
    export J_HOSTFILE=/etc/JARVICE/nodes
  fi
fi
