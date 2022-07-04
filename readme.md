# 2.11BSD GitHub Action

This Action allows you to test builds under a 2.11BSD emulated PDP-11
environment.

## Usage

An example workflow file:

```
on: [push]

jobs:
  checks:
    runs-on: ubuntu-latest
    name: Verifies that we can talk to the PDP
    steps:
      - name: checkout
        uses: actions/checkout@v3
      - name: run uname
        uses: AaronJackson/2.11BSD-Action
        with:
          path: /usr/src/sys/
          run: |
			  cd GENERIC
			  make

```
