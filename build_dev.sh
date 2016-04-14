#!/bin/bash

cd server
python server.py &

cd -
elm css StyleSheets.elm
elm package install -y; elm live Main.elm --open --output=built/elm.js
