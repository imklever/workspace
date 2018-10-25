#!/bin/bash

#curl -i \
curl \
    -H "Content-Type: application/json" \
    -d '{
            "auth": 
            {
                "identity": 
                {
                    "methods": ["password"],
                    "password":
                    {
                        "user":
                        {
                            "name": "admin",
                            "domain": { "id": "default" },
                            "password": "secret"
                        }   
                    }
                }
            }
        }' \
"http://10.240.217.137/identity/v3/auth/tokens" | python -m json.tool

#curl 10.240.217.137/identity/v3/domains
