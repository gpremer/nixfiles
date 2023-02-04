#!/usr/bin/env bash

aws ecr get-login-password --profile awv --region eu-west-1 | docker login --username AWS --password-stdin https://162510209540.dkr.ecr.eu-west-1.amazonaws.com/
