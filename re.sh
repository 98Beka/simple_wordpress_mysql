#!/bin/sh
docker build -t srvr .
docker run -it --rm -p 5050:5050 srvr
