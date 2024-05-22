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
5. Local command line

However due to the way that they are built they should work on most CICD platforms where you can run arbitrary scripts.

We provide a [script](https://github.com/CICDToolbox/get-all-tools) which pulls the latest copy of all the CICD tools and
places them in a local bin directory to allow them to be run any time locally for added validation.

## Configuration Options

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
```
--------------------------------------------------------------------- Stage 1: Parameters --
 Included Files: tests
---------------------------------------------------------- Stage 2: Install Prerequisites --
 [  OK  ] file is already installed
--------------------------------------------------------------- Stage 3: Run file (v5.41) --
 [  OK  ] tests/test.py
------------------------------------------------------------------------- Stage 4: Report --
 Total: 1, OK: 1, Failed: 0, Skipped: 0
----------------------------------------------------------------------- Stage 5: Complete --
```
## File Identification

Target files are identified using the following code:

```shell
file -b "${filename}" | grep -qE '^(REGEX)'

AND

[[ ${filename} =~ \.(REGEX)$ ]]
```

## Tools built using this template

| Name                                                                              | Purpose                                                                                                            |
| :-------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------- |
| [Action Lint](https://github.com/CICDToolbox/action-lint)                         | Validate your GitHub action files using [actionlint](https://github.com/rhysd/actionlint).                         |
| [Awesomebot](https://github.com/CICDToolbox/awesomebot)                           | Link check your files with [awesome_bot](https://rubygems.org/gems/awesome_bot).                                   |
| [Bandit](https://github.com/CICDToolbox/bandit)                                   | Inspect your Python projects for security issues using [bandit](https://pypi.org/project/bandit/).                 |
| [Hadolint](https://github.com/CICDToolbox/hadolint)                               | Validate your Dockerfiles using [hadolint](https://github.com/hadolint/hadolint).                                  |
| [JSON Lint](https://github.com/CICDToolbox/json-lint)                             | Validate your JSON files using [jq](https://stedolan.github.io/jq/).                                               |
| [Markdown Lint](https://github.com/CICDToolbox/markdown-lint)                     | Validate your markdown files in using [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli).       |
| [Perl Lint](https://github.com/CICDToolbox/perl-lint)                             | Validate your Perl scripts using the native perl linter.                                                           |
| [PHP Lint](https://github.com/CICDToolbox/php-lint)                               | Validate your PHP code using the native php linter.                                                                |
| [Puppet Lint](https://github.com/CICDToolbox/puppet-lint)                         | Validate your Puppet files using [puppet-lint](https://rubygems.org/gems/puppet-lint).                             |
| [Pur](https://github.com/CICDToolbox/pur)                                         | Verify your Python projects requirements.txt for updates using [pur](https://pypi.org/project/pur/).               |
| [PyCodeStyle](https://github.com/CICDToolbox/pycodestyle)                         | Inspect your Python projects for code smells using [pycodestyle](https://pypi.org/project/pycodestyle/).           |
| [PyDocStyle](https://github.com/CICDToolbox/pydocstyle)                           | Validate your Python project documentation for compliance with [pydocstyle](https://pypi.org/project/pydocstyle/). |
| [Pylama](https://github.com/CICDToolbox/pylama)                                   | Validate your Python project documentation for compliance with [pylama](https://pypi.org/project/pylama/).         |
| [Pylint](https://github.com/CICDToolbox/pylint)                                   | Inspect your Python projects for code smells using [pylint](https://pypi.org/project/pylint/).                     |
| [Reek](https://github.com/CICDToolbox/reek)                                       | Inspect your Ruby code for code smells using [reek](https://rubygems.org/gems/reek).                               |
| [Rubocop](https://github.com/CICDToolbox/rubocop)                                 | Perform static code analysis on Ruby code using [rubocop](https://rubygems.org/gems/rubocop).                      |
| [ShellCheck](https://github.com/CICDToolbox/shellcheck)                           | Perform static code analysis on shell scripts using [ShellCheck](https://github.com/koalaman/shellcheck).          |
| [Validate Citations File](https://github.com/CICDToolbox/validate-citations-file) | Validate CITATIONS.cff using [cffconvert](https://pypi.org/project/cffconvert/).                                   |
| [YAML Lint](https://github.com/CICDToolbox/yaml-lint)                             | Validate your yaml files in CI/CD pipelines using [yamllint](https://pypi.org/project/yamllint/).                  |

<br />
<p align="right"><a href="https://wolfsoftware.com/"><img src="https://img.shields.io/badge/Created%20by%20Wolf%20on%20behalf%20of%20Wolf%20Software-blue?style=for-the-badge" /></a></p>
