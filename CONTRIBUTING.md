#Documentation

##Github

###Fork CalCentral Repository
```bash
git clone git@github.com:[your_github_acct]/calcentral.git
```


###Configuring Remotes
To keep track of original repository, add a remote named upstream. (This is a one time change.)

```bash
git remote add upstream https://github.com/ets-berkeley-edu/calcentral.git
```


###Pull in upstream changes
To sync changes from upstream repository to your forked repository run the following code.
Follow this step everytime you want update your forked repository with changes in original repository.

```bash
git fetch upstream
# Fetches any new changes from the original repository

git merge upstream/master
# Merges any changes fetched into your working files
```

For more information on configuring remotes and updating forked repository check this [link](https://help.github.com/articles/fork-a-repo#pull-in-upstream-changes)


###Creating a new branch.
To create a new github branch 

```bash
git checkout -b <new branch name> ets-berkeley-edu/master
```


###Make changes in a branch and push changes.
```bash
git add .
# git add . adds all the files with changes. 
# Individual files can also added using the command git add <filename>

git commit -m "commit message"
git push origin <new branch name>
```


###Creating a pull request
After pushing the changes, a pull request can be created from the forked repository in github.

1. Log in to github account and click on the "Compare and Review" button.
2. Review the changes made.
3. Click "Send Pull Request".

Check this [link](https://help.github.com/articles/creating-a-pull-request) for more details


###Updating a Pull request.
After making a pull request, if there are any changes to be done in the same PR.

1. Checkout the same branch in which the changes were previously made.
2. Make new changes and run the following commands.

```bash
git add <filename>
#Or git add . to add all the files with changes

git commit --amend
git push -f origin <branch name>
# Note: Use -f for changes to be pushed when updating a PR
```


##Front-end Testing
Front-end testing can be done by running jasmine tests usin the following command.

```bash
rake jasmine
```


##Back-end Testing
Back-end testing can be done by running the following command.

```bash
rspec spec
```