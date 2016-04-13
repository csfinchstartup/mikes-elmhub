#!/bin/bash

cd server
virtualenv env
pip install -r requirements.txt
python server.py &

open ../index.html
