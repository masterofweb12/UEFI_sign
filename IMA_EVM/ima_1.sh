#!/bin/sh


#
#
#  kernel params
#  ima_appraise=fix ima_policy=appraise_tcb
#

time find / -fstype ext4 -type f -uid 0 -exec dd if='{}' of=/dev/null count=0 status=none \;





