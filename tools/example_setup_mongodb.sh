#!/bin/bash

export ARTDAQ_DATABASE_URI="mongodb://mu2edaq:zrDBG6kb9TEVe2HP@192.168.157.13:28047,192.168.157.14:28047/mu2e_db?replicaSet=rs0&authSource=admin"

export LD_LIBRARY_PATH=$MONGODB_FQ_DIR/lib64:$LD_LIBRARY_PATH
export ARTDAQ_DATABASE_CONFDIR=/home/mu2edb/database/config
