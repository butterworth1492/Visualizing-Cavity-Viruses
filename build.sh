#!/bin/env bash
# Copyright (c) 2014, butterworth1492
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Author:  Jason Miller
# Purpose: This was HASTILY written in about four hours.  It is a proof-of-concept
#          that explores the viability of having novice security analysts reverse-
#          engineering binary files by generating images that represent the
#          binaries in various ways.  The idea is the compare the clean, original
#          binary against a potentially-infected version to see if anything stands
#          out to the naked eye.
#
#          To patch the legitimate binaries with shellcode, we used the Backdoor
#          Factory (https://github.com/secretsquirrel/the-backdoor-factory)
#          and then used the tools created by Aldo Cortesi (https://github.com/cortesi)
#          to generate the representative images.
#
#          This script supports 4 visualization techniques (as allowed by Mr. 
#          Cortesi's 'binvis' tool).  They are "entropy", "hilbert", "gradient",
#          and "class".
#
# Usage:   Select some random windows (may work with others, but was tested with
#          Win64 binaries) exe's and dll's and put them in the 'bin/clean' directory.
#          Run this script...
#               sh build.sh hilbert
#          After the script is done, open 'html/index' in a web browser.

# Vars
CLEANDIR=bin/clean
INFECTEDDIR=bin/infected
TEMPLATEDIR=template
LOG=build.log
HTMLDIR=html
INDEX=${HTMLDIR}/index.html

# Duh
usage() { 
    echo "Usage: ${0} (entropy|gradient|hilbert|class)" >&2 
    exit 1
  }

# Check command-line argument
[ ${#} -lt 1 ] && usage || TYPE=${1}

# This next couple of lines may look strange but it's a simple way to allow a 
# substring of a valid argument if the user is lazy.
echo "entropy gradient hilbert class" | grep ${TYPE} >/dev/null 2>&1
[ ${?} -ne 0 ] && usage 

# Clean up from last time
rm -rf ${CLEANDIR}/*.png ${INFECTEDDIR}/* ${HTMLDIR}/* ${LOG}

# Build the patched binaries
for file in $(ls ${CLEANDIR}); do
  echo "Generating patch file for ${file} ..."
  yes 1 | backdoor-factory -qJ -f ${CLEANDIR}/${file} -H 127.0.0.1 -P 8080 -s reverse_shell_tcp >> ${LOG} 2>&1
  [ ${?} -ne 0 ] && echo "WARNING: Backdoor Factory didn't like '${file}'.  Skipping."
  mv backdoored/${file} ${INFECTEDDIR} 2>/dev/null
done
rm -rf backdoored

# Build the entropy maps for the clean binaries
for file in $(ls ${CLEANDIR}); do
  echo "Generating entropy for ${CLEANDIR}/${file} ..."
  python scurve/binvis -c ${TYPE} ${CLEANDIR}/${file} ${CLEANDIR}/${file}_map.png 
done

# Build the entropy maps for the infected binaries
for file in $(ls ${INFECTEDDIR}); do
  echo "Generating entropy for ${INFECTEDDIR}/${file} ..."
  python scurve/binvis -c ${TYPE} ${INFECTEDDIR}/${file} ${INFECTEDDIR}/${file}_map.png 
done

# Make the output directory and copy over the entropy-mapped images
mkdir -p ${HTMLDIR}/clean ${HTMLDIR}/infected
cp -rp bin/clean/*.png ${HTMLDIR}/clean
cp -rp bin/infected/*.png ${HTMLDIR}/infected

# Build the output files
cat ${TEMPLATEDIR}/head.html.part | sed "s/REPLACE_ME/${TYPE}/" >> ${INDEX}

for file in $(ls ${CLEANDIR} | grep -v png); do
  echo "<li> <a href=\"${file}.html\" target=\"i_am_the_iframe\">${file}</a></li>" >> ${INDEX}
  cat ${TEMPLATEDIR}/entry.html.part | sed "s/REPLACE_ME/${file}/" > ${HTMLDIR}/${file}.html
done

cat ${TEMPLATEDIR}/tail.html.part >> ${INDEX}

