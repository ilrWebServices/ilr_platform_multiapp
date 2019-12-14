# ILR Proxy and Drupal 8 Deployment Repo

This codebase exists solely to combine the Drupal 8 ILR site and the ILR website proxy repositories for hosting on platform.sh.

# Requirements

- `git` 2.10 or higher

# Setup

To clone this repository along with the embedded submodules, use the `--recurse-submodules` argument. For example:

```
$ git clone --recurse-submodules git@github.com:ilrWebServices/ilr_platform_multiapp.git
```

Add a git remote to the Platform.sh project:

```
$ git remote add platform yf4o2w34wqxm6@git.us-2.platform.sh:yf4o2w34wqxm6.git
```

# Updating

To update either of the applications (proxy or D8), run the following:

```
$ git pull origin
$ git submodule update --remote
```

Then run a `git diff --submodules` to see a list of the new commits in each project. You can use that output in your commit message.

If the changes look correct, commit them.

# Deployment

After updating the project submodules, push the project to the platform remote:

```
git push platform
```

Be sure to push your changes to `origin`, too, via `git push origin`. While not essential, it provides a remote backup of the repository outside of our hosting provider.
