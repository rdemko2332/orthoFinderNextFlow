#!/usr/bin/env bash

set -euo pipefail

if [ "$allBlast" = true ]; then

    assignGroupsForPeripherals.pl --result $diamondInput \
                                  --groupsFile $groupsFile \
			          --output groups.txt \
				  --allBlast

else

    assignGroupsForPeripherals.pl --result $diamondInput \
                                  --groupsFile $groupsFile \
			          --output groups.txt 
    
fi




