<!-- markdownlint-disable -->
<p align="center">
    <a href="https://github.com/CICDToolbox/">
        <img src="https://cdn.wolfsoftware.com/assets/images/github/organisations/cicdtoolbox/black-and-white-circle-256.png" alt="CICDToolbox logo" />
    </a>
    <br />
    <a href="https://github.com/CICDToolbox/template/actions/workflows/cicd.yml">
        <img src="https://img.shields.io/github/actions/workflow/status/CICDToolbox/template/cicd.yml?branch=master&label=build%20status&style=for-the-badge" alt="Github Build Status" />
    </a>
    <a href="https://github.com/CICDToolbox/template/blob/master/LICENSE.md">
        <img src="https://img.shields.io/github/license/CICDToolbox/template?color=blue&label=License&style=for-the-badge" alt="License">
    </a>
    <a href="https://github.com/CICDToolbox/template">
        <img src="https://img.shields.io/github/created-at/CICDToolbox/template?color=blue&label=Created&style=for-the-badge" alt="Created">
    </a>
    <br />
    <a href="https://github.com/CICDToolbox/template/releases/latest">
        <img src="https://img.shields.io/github/v/release/CICDToolbox/template?color=blue&label=Latest%20Release&style=for-the-badge" alt="Release">
    </a>
    <a href="https://github.com/CICDToolbox/template/releases/latest">
        <img src="https://img.shields.io/github/release-date/CICDToolbox/template?color=blue&label=Released&style=for-the-badge" alt="Released">
    </a>
    <a href="https://github.com/CICDToolbox/template/releases/latest">
        <img src="https://img.shields.io/github/commits-since/CICDToolbox/template/latest.svg?color=blue&style=for-the-badge" alt="Commits since release">
    </a>
    <br />
    <a href="https://github.com/CICDToolbox/template/blob/master/.github/CODE_OF_CONDUCT.md">
        <img src="https://img.shields.io/badge/Code%20of%20Conduct-blue?style=for-the-badge" />
    </a>
    <a href="https://github.com/CICDToolbox/template/blob/master/.github/CONTRIBUTING.md">
        <img src="https://img.shields.io/badge/Contributing-blue?style=for-the-badge" />
    </a>
    <a href="https://github.com/CICDToolbox/template/blob/master/.github/SECURITY.md">
        <img src="https://img.shields.io/badge/Report%20Security%20Concern-blue?style=for-the-badge" />
    </a>
    <a href="https://github.com/CICDToolbox/template/issues">
        <img src="https://img.shields.io/badge/Get%20Support-blue?style=for-the-badge" />
    </a>
</p>

## Overview

This is the template that we use when we are creating any of the tools within the [CICD Toolbox](https://github.com/CICDToolbox). 

All of the tools have been tested against:

1. GitHub Actions
2. Travis CI
3. CircleCI
4. BitBucket pipelines

However due to the way that they are built they should work on most CICD platforms where you can run arbitrary scripts.

You can of course run this scripts locally and even linked them into pre-commit hooks if you wish.

The following environment variables can be set in order to customise the script.

| Name          | Default Value  | Purpose                                                                                                                                                                         |
| :------------ | :------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| INCLUDE_FILES | Unset          | A comma separated list of files to include for being scanned. You can also use `regex` to do pattern matching.                                                                  |
| EXCLUDE_FILES | Unset          | A comma separated list of files to exclude from being scanned. You can also use `regex` to do pattern matching.                                                                 |
| NO_COLOR      | False          | Turn off the color in the output. (It is turned off by default inside of pipelines)                                                                                             |
| REPORT_ONLY   | False          | Generate the report but do not fail the build even if an error occurred.                                                                                                        |
| SHOW_ERRORS   | True           | Show the actual errors instead of just which files had errors.                                                                                                                  |
| SHOW_SKIPPED  | False          | Show which files are being skipped.                                                                                                                                             |
| WHITELIST     | Unset          | A comma separated list of files to be excluded from being checked.                                                                                                              |

> If you set INCLUDE_FILES - it will skip ALL files that do not match, including anything in EXCLUDE_FILES.

## Example Output

Running the pipeline locally against this repository and using INCLUDE_FILES="tests" results in the follow:

------------------------------------------------------------------------------------------------------------------------------- Stage 1: Parameters --
 Included Files: tests
-------------------------------------------------------------------------------------------------------------------- Stage 2: Install Prerequisites --
 [  OK  ] file is already installed
------------------------------------------------------------------------------------------------------------------------- Stage 3: Run file (v5.41) --
 [  OK  ] tests/test.py
----------------------------------------------------------------------------------------------------------------------------------- Stage 4: Report --
 Total: 1, OK: 1, Failed: 0, Skipped: 0
--------------------------------------------------------------------------------------------------------------------------------- Stage 5: Complete --

## File Identification

Target files are identified using the following code:

```shell
file -b "${filename}" | grep -qE '^(REGEX)'

AND

[[ ${filename} =~ \.(REGEX)$ ]]

<br />
<p align="right"><a href="https://wolfsoftware.com/"><img src="https://img.shields.io/badge/Created%20by%20Wolf%20on%20behalf%20of%20Wolf%20Software-blue?style=for-the-badge" /></a></p>
