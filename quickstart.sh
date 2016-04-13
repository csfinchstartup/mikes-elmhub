#!/bin/bash

cd server
virtualenv env
pip install flask
python server.py &

open ../index.html
