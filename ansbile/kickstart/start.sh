#!/bin/bash
ansible-playbook --inventory-file hosts --extra-vars var.yaml playbook.yaml
