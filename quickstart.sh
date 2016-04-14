#!/bin/bash

cd server
python server.py &

cd -
open index.html
