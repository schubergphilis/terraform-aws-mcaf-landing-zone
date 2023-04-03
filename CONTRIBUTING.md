# Contributing

## Coding Guidelines

- The terraform language has some [style conventions](https://developer.hashicorp.com/terraform/language/syntax/style) which must be followed for consistency between files and modules written by different teams.

## Opening a pull request

- We require pull request titles to follow the [conventional commits specification](https://www.conventionalcommits.org/en/v1.0.0/)

- Labels are automatically added to your PR based on certain keywords in the `title`, `body`, and `branch` . You are able to manually add or remove labels from your PR, the following labels are allowed: `breaking`, `enhancement`, `feature`, `bug`, `fix`, `security`, `documentation`.

## Release flow

1. Every time a PR is merged, a draft release note is created or updated to add an entry for this PR. The release version is automatically incremented based on the labels specified.

2. When you are ready to publish the release, you can use the drafted release note to do so. `MCAF Contributors` are able to publish releases. If you are an `MCAF Contributor` and want to publish a drafted release:
    - Browse to the release page
    - Edit the release you want to publish (click on the pencil)
    - Click `Update release` (the green button at the bottom of the page)

If a PR should not be added to the release notes and changelog, add the label `no-changelog` to your PR.

## Local Development

To ease local development, [pre-commit](https://pre-commit.com/) configuration has been added to the repository. Pre-commit is useful for identifying simple issues before creating a PR:

To use it, follow these steps:

1. Installation:
    - Using Brew: `brew install tflint`
    - Using Python: `pip3 install pre-commit --upgrade`
    - Using Conda: `conda install -c conda-forge pre-commit`

2. Run the pre-commit hooks against all the files (the first time run might take a few minutes):
`pre-commit run -a`

3. (optional) Install the pre-commit hooks to run before each commit:
`pre-commit install`
