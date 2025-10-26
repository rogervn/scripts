#!/bin/bash

unset LD_PRELOAD
exec /opt/Heroic/heroic "$@"
