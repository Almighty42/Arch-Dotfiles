#!/bin/bash

if [ -f /tmp/work_mode ]; then
	echo "message-error 'Work mode is active: private tabs are blocked'" >> "$QUTE_FIFO"
else
	echo "open -p" >> "$QUTE_FIFO"
fi
