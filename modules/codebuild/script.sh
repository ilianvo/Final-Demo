#!/bin/bash

aws codebuild import-source-credentials \
  --token "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" \
  --server-type GITHUB \
  --auth-type PERSONAL_ACCESS_TOKEN \
  --region eu-west-3
