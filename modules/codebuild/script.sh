#!/bin/sh
aws --region eu-west-3 codebuild import-source-credentials \
                                                             --token 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 \
                                                             --server-type GITHUB \
                                                             --auth-type PERSONAL_ACCESS_TOKEN
