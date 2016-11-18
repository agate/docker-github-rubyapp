#!/bin/bash

echo "$GITHUB_SSH_KEY" > ~/.ssh/github_key && chmod 600 ~/.ssh/github_key
ruby -e 'ENV.map{ |e| puts "env #{e.first};" }' > /etc/nginx/main.d/rb_env.conf

GIT_BRANCH=${GIT_BRANCH:-"master"}

cd /home/app

if [ -d webapp/.git ]; then
  echo "webapp already exist"
elif [ -z "$GIT_PATH" ]; then
  echo "clone ${GITHUB_REPO} @ ${GIT_BRANCH}"
  git clone $GITHUB_REPO --branch $GIT_BRANCH --single-branch webapp
else
  echo "clone ${GITHUB_REPO} @ ${GIT_BRANCH} only ${GIT_PATH}"
  git clone -n $GITHUB_REPO --branch $GIT_BRANCH --single-branch webapp
  cd webapp
  git config core.sparseCheckout true
  echo "$GIT_PATH" >> .git/info/sparse-checkout
  git checkout $GIT_BRANCH
  mv /home/app/webapp/$GIT_PATH/* /home/app/webapp
fi

chown -R app:app /home/app/webapp

su - app -c "cd /home/app/webapp; bundle install"
