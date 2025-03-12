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

This is the [template](template.sh) that we use when we are creating any of the tools within the [CICD Toolbox](https://github.com/CICDToolbox). 

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

There are a lot of configuration options for this [template](template.sh). They are all documented within the script, but
we have added some high-level documentation for each here as well.

| Name                           | Purpose                                                                                                                                                        |
| :----------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BANNER_NAME                    | The name to show on the banner part of the report.                                                                                                             |
| BASE_COMMAND                   | What is base name of the package? (Shows on the report output)                                                                                                 |
| DEBUG_MODE                     | Disable/ Enable extra debugging within the run_command function.                                                                                               |
| EXTRA_PARAMETERS               | Extra parameters are options that are passed as configuration to the script that are needed for the command execution.                                         |
| FILE_NAME_SEARCH_PATTERN       | File name to match. Regex based - used if FILE_TYPE_SEARCH_PATTERN doesn't match a file or is empty. If a file doesn't match either pattern it is 'unmatched'. |
| FILE_TYPE_SEARCH_PATTERN       | File type to match (comes from file -b). Regex based but ignored if left empty.                                                                                |
| INSTALL_COMMAND                | How to install the require tool? This can be empty if it is a built in bash command or similar.                                                                |
| INSTALL_REQUIREMENTS_FROM_REPO | Run pip install -r requirements.txt to install repo specific requirements. [Only useful for python/pip based tools]                                            |
| INSTALLED_CHECK                | How do we check to see if it is already installed? Leave empty if you want to force install (docker for example).                                              |
| PACKAGE_NAME                   | What package are we installing (or url for repo to install from)?                                                                                              |
| PREREQUISITE_COMMANDS          | What prerequisites does this pipeline have? E.g. gem, pip3, docker, npm etc.                                                                                   |
| REDIRECTED                     | Needed for tools that require file contents to be redirected rather than accessed via a path.                                                                  |
| SCAN_ROOT                      | The base path to use when looking for matching files.                                                                                                          |
| TEST_COMMAND                   | The command string to run when running a tests.                                                                                                                |
| UPDATE_PIP                     | Force an update to pip before installing the package. [Only useful for python/pip based tools]                                                                 |
| VERSION_COMMAND                | How to get the current version of the tool that we are using.                                                                                                  |

## Usage Options

The following environment variables can be set in order to customise the script during run time.

| Name           | Default Value  | Purpose                                                                                                         |
| :------------- | :------------: | :-------------------------------------------------------------------------------------------------------------- |
| INCLUDE_FILES  | Unset          | A comma separated list of files to include for being scanned. You can also use `regex` to do pattern matching.  |
| EXCLUDE_FILES  | Unset          | A comma separated list of files to exclude from being scanned. You can also use `regex` to do pattern matching. |
| NO_COLOR       | False          | Turn off the color in the output. (It is turned off by default inside of pipelines)                             |
| REPORT_ONLY    | False          | Generate the report but do not fail the build even if an error occurred.                                        |
| SHOW_ERRORS    | True           | Show the actual errors instead of just which files had errors.                                                  |
| SHOW_FILTERED  | False          | Show which files are being filtered (Those that match the EXCLUDE_FILES pattern).                               |
| SHOW_UNMATCHED | False          | Show which files which did not meet the file identification criteria.                                           |

## Example Output

Running the demo [pipeline](pipeline.sh) locally against this repository results in the follow:
```
------------------------------------------------------------------------ Run file (v5.41) --
 [ ✅ ] tests/test.py
---------------------------------------------------------------------------------- Report --
 Total: 1, Passed: 1, Failed: 0, Filtered: 0, Unmatched: 0
-------------------------------------------------------------------------------- Complete --
```

| Name      | Icon | Description                                                                            |
| :-------: | :--: | :------------------------------------------------------------------------------------- |
| OK        |  ✅  | The tests for this file passed.                                                        |
| Failed    |  ❌  | The tests for this file failed.                                                        |
| Filtered  |  🟡  | This file matches the EXCLUDE_FILES pattern.                                           |
| Unmatched |  🔵  | This file did not meet the file identification criteria (or an INCLUDE_FILES pattern). |

## File Identification

Target files are identified using the following code:

```shell
file -b "${filename}" | grep -qE '^(REGEX)'

AND

[[ ${filename} =~ \.(REGEX)$ ]]
```

| Name                     | Description                                                                                                                                                    |
| :----------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FILE_TYPE_SEARCH_PATTERN | File type to match (comes from file -b). Regex based but ignored if left empty.                                                                                |
| FILE_NAME_SEARCH_PATTERN | File name to match. Regex based - used if FILE_TYPE_SEARCH_PATTERN doesn't match a file or is empty. If a file doesn't match either pattern it is 'unmatched'. |


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
