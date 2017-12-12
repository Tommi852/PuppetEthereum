#!/bin/bash
sudo puppet apply --modulepath modules/ -e 'class {"ethereum":}'
