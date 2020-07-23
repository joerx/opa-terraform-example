#!/bin/bash

terraform plan -out plan.bin
terraform show -json plan.bin > plan.json

# res=$(opa eval -i plan.json -d policies "data.example.terraform.tags.pass" | jq '.result[0].expressions[0].value')

# echo "Pass: $res"
