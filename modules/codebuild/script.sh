#!/bin/sh
aws --region eu-west-3 codebuild import-source-credentials \
                                                             --token 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 \
                                                             --server-type GITHUB \
                                                             --auth-type PERSONAL_ACCESS_TOKEN
