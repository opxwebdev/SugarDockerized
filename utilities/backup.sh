#!/bin/bash

# Enrico Simonetti
# enricosimonetti.com

if [ -z $1 ]
then
    echo Provide the backup suffix as script parameters
else
    # check if the stack is running
    running=`docker ps | grep sugar-web1 | wc -l`

    if [ $running -gt 0 ]
    then
        # running

        # enter the repo's root directory
        REPO="$( dirname ${BASH_SOURCE[0]} )/../"
        cd $REPO

        BACKUP_DIR="backups/backup_$1"
        echo Backing up sugar to \"$BACKUP_DIR\"

        # if it is our repo, and the source exists, and the destination does not
        if [ -f '.gitignore' ] && [ -d 'data' ] && [ ! -d $BACKUP_DIR ] && [ -d 'data/app/sugar'  ]
        then
            mkdir -p $BACKUP_DIR
            sudo rsync -a data/app/sugar $BACKUP_DIR/
            if [ -d $BACKUP_DIR/sugar ]
            then
                echo Application files backed up on $BACKUP_DIR/sugar
            else
                echo Application files NOT backed up!!!
                echo Please discard the current backup
            fi
            mysqldump -h docker.local -u root -proot --order-by-primary --single-transaction -Q --opt --skip-extended-insert sugar > $BACKUP_DIR/sugar.sql
    
            if [ \( -f $BACKUP_DIR/sugar.sql \) -a \( "$?" -eq 0 \) ]
            then
                echo Database backed up on $BACKUP_DIR/sugar.sql
            else
                echo Database NOT backed up!!! Please check that the \"sugar\" database exists!
                echo Please discard the current backup
            fi
        else
            if [ ! -d 'data' ]
            then
                echo \"data\" cannot be empty, the command needs to be executed from within the clone of the repository
            fi

            if [ ! -d 'data/app/sugar' ]
            then
                echo \"data/app/sugar\" cannot be empty
            fi

            if [ -d $BACKUP_DIR ]
            then
                echo $BACKUP_DIR exists already
            fi
        fi

    else
        echo The stack is not running, please start the stack first
    fi
fi
