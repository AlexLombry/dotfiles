### First Method

Deleting the `.git` folder may cause problems in our git repository. If we want to delete all of our commits history, but keep the code in its current state, try this:

```
# Check out to a temporary branch:
git checkout --orphan TEMP_BRANCH

# Add all the files:
git add -A

# Commit the changes:
git commit -am "Initial commit"

# Delete the old branch:
git branch -D master

# Rename the temporary branch to master:
git branch -m master

# Finally, force update to our repository:
git push -f origin master
```

This will not keep our old commits history around. **But if this doesn't work, try the next method below.**

### Second Method

```
# Clone the project, e.g. `myproject` is my project repository:
git clone https://github/heiswayi/myproject.git

# Since all of the commits history are in the `.git` folder, we have to remove it:
cd myproject

# And delete the `.git` folder:
git rm -rf .git

# Now, re-initialize the repository:
git init
git remote add origin https://github.com/heiswayi/myproject.git
git remote -v

# Add all the files and commit the changes:
git add --all
git commit -am "Initial commit"

# Force push update to the master branch of our project repository:
git push -f origin master
```
**NOTE:** You might need to provide the credentials for your GitHub account.
