Visualizing-Cavity-Viruses
==========================

STANDARD DISCLAIMER: Unlike most people who commit code to github, my 
primary motivation is simply to find a place for interesting code to live 
if I don't want to lose track of it.  You'll find my coding styles vary 
from project to project and that I pay little attention to community 
standards or feedback.  I do all that stuff at my day job.  Enjoy!  

This was HASTILY written in about four hours.  It is a proof-of-concept
that explores the viability of having novice security analysts reverse-
engineering binary files by generating images that represent the
binaries in various ways.  The idea is the compare the clean, original
binary against a potentially-infected version to see if anything stands
out to the naked eye.

To patch the legitimate binaries with shellcode, we used the Backdoor
Factory (https://github.com/secretsquirrel/the-backdoor-factory)
and then used the tools created by Aldo Cortesi (https://github.com/cortesi)
to generate the representative images.

This script supports 4 visualization techniques (as allowed by Mr. 
Cortesi's 'binvis' tool).  They are "entropy", "hilbert", "gradient",
and "class".

Usage:
Select some random windows (may work with others, but was tested with
Win64 binaries) exe's and dll's and put them in the 'bin/clean' directory.
Run this script...
    sh build.sh hilbert
After the script is done, open 'html/index' in a web browser.

