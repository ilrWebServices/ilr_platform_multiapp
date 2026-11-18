update-drupal:
    git submodule update --remote && git diff --submodule | cat
