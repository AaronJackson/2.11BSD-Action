# 2.11BSD GitHub Action

This Action allows you to test builds under a 2.11BSD emulated PDP-11
environment.

## Usage

From your own GitHub repository, you can use this GitHub Action to
test builds of your own against different patch levels of 2.11BSD. By
default, your action will be run against the latest patch level.

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
        uses: AaronJackson/2.11BSD-Action@v2
        with:
          path: /usr/src/sys/
          patch_level: 479
          run: |
            cd GENERIC
            make

```

## Patch Levels

Each patch available (to date) has been applied sequentially using a
GitHub workflow available in this repository
(`.github/workflows/patches.yml`). This is a bit of a mess but only
needs to be run once. All steps described in each patch is performed
before uploading the upgraded disk image to an S3 bucket - you are
welcome to download these for your own use. Below is a list of all
patch levels and their public S3 bucket link. They are all built using
the `SIMH` kernel from the original SIMH disk image, but the `GENERIC`
kernel is also rebuilt when necessary and provided in `/genunix`.

| Patch | URL                                                                          |
| ---   | ---                                                                          |
| 457   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-457.dsk.gz |
| 458   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-458.dsk.gz |
| 459   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-459.dsk.gz |
| 460   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-460.dsk.gz |
| 461   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-461.dsk.gz |
| 462   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-462.dsk.gz |
| 463   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-463.dsk.gz |
| 464   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-464.dsk.gz |
| 465   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-465.dsk.gz |
| 466   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-466.dsk.gz |
| 467   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-467.dsk.gz |
| 468   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-468.dsk.gz |
| 469   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-469.dsk.gz |
| 470   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-470.dsk.gz |
| 471   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-471.dsk.gz |
| 472   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-472.dsk.gz |
| 473   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-473.dsk.gz |
| 474   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-474.dsk.gz |
| 475   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-475.dsk.gz |
| 476   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-476.dsk.gz |
| 477   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-477.dsk.gz |
| 478   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-478.dsk.gz |
| 479   | https://asjackson-211bsd-ci.s3.fr-par.scw.cloud/211bsd-ci-479.dsk.gz |

These images can be written to a SCSI (SCSI2SD if you want) and run on
a real PDP-11, if you have one.
