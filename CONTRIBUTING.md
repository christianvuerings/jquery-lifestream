# Contributing

## Github

### Fork CalCentral Repository

```bash
git clone git@github.com:[your_github_acct]/calcentral.git
```


### Configuring Remotes
To keep track of original repository, add a remote named ets. (This is a one time operation.)

```bash
git remote add ets https://github.com/ets-berkeley-edu/calcentral.git
```


### Pull in upstream changes
To sync changes from remote ets repository to your forked repository run the following code.
Follow this step every time you want to update your forked repository with changes in the original repository.

```bash
git fetch ets
# Fetches any new changes from the original repository

git merge ets/master
# Merges any changes fetched into your working files
```

For more information on configuring remotes and updating forked repository check this [link](https://help.github.com/articles/fork-a-repo#pull-in-upstream-changes).


### Creating a new branch.
To create a new GitHub branch

```bash
git checkout -b CLC-XXXX ets/master
# The new branch name should be of the format CLC-XXXX where XXXX is the Jira Issue ID.
```


### Make changes in a branch and push changes.

```bash
git add .
# git add . adds all the files with changes.
# Individual files can also added using the command git add <filename>

git commit -m "[CLC-XXXX] - commit message"
git push origin CLC-XXXX
```

### Creating a pull request
After pushing the changes, a pull request can be created from the forked repository in github.

1. Log in to GitHub account and click on the "Compare and Review" button.
2. Review the changes made.
3. Click "Send Pull Request".

If you need more help on creating pull requests, feel free to read the [creating pull requests post]((https://help.github.com/articles/creating-a-pull-request)) on GitHub.


### Updating a pull request.
To make changes to a pull request.

1. Checkout the same branch in which the changes were previously made.
2. Make new changes and run the following commands.

```bash
git add <filename>
# Or git add . to add all the files with changes

git commit --amend
git push -f origin <branch name>
# Note: Use -f for changes to be pushed when updating a PR
```


## Front-end Linting
Front-end linting (checking for errors / code styles)

```bash
jshint .
```


## Back-end Testing
Back-end testing can be done by running the following command.

```bash
rspec spec
```
