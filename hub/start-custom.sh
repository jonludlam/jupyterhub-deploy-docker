#!/bin/bash

# User should be set to root in the docker file before calling this.

set -e
set -x

userdel instructor

# Home dir has been mounted by jupyterhub as a docker volume
shopt -s dotglob
for i in /home/instructor/*; do ln -sf $i /home/${NB_USER}; done
shopt -u dotglob

NB_GROUP=instructor

# User home directory will already exist because DockerSpawner mounted a docker volume at /home/$NB_USER
groupadd -g ${NB_GID} ${NB_GROUP}
useradd -u ${NB_UID} ${NB_USER} --gid ${NB_GROUP}

cd /home/${NB_USER}
###################################################################################



chmod 600 /tmp/students.csv
chown ${INSTRUCTOR_UID}:${INSTRUCTOR_GID} /tmp/students.csv
chown ${INSTRUCTOR_UID}:${INSTRUCTOR_GID} /srv/nbgrader/${COURSE_NAME}
echo ${NBGRADER_DB_URL} > /srv/nbgrader/${COURSE_NAME}/nbgrader_db.url
unset NBGRADER_DB_URL

# Make exchange directory readable and writable by everyone.
# Take exchange directory as environment variable later.
# This should be same volume mounted on each user's docker container.
chmod 777 /srv/nbgrader/exchange
chown ${INSTRUCTOR_UID}:${INSTRUCTOR_GID} /srv/nbgrader/exchange

ln -sf /srv/nbgrader/${COURSE_NAME} /home/$NB_USER/${NOTEBOOK_DIR}/${COURSE_NAME} 

chown -R ${NB_USER}:${NB_GROUP} /home/${NB_USER}

export PATH=$PATH:/home/${NB_USER}/.local/bin
# Import students.
su $NB_USER -c "env PATH=$PATH nbgrader db student import /tmp/students.csv"

################## Enable extensions for instructors #############################
jupyter nbextension enable nbgrader --user --py
jupyter serverextension enable nbgrader --user --py

################################################################################


# Start the single user notebook.
exec /home/${NB_USER}/.local/bin/start-singleuser-custom.sh $*
