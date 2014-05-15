#!/bin/bash
libpath=${0%%clean_storage_env*}
pypath="$libpath/py"
cd $libpath/.. &&. ./config && cd -
. $libpath/common_func.sh
. $libpath/function.sh

create_storage_env()
{
    run create_storage_property
    run create_storage_server
    run create_storage_pool
} 

#### Clean up test ENV ###
clean_storage_env()
{
    #Delete storage pool
    run delete_storage_pool
    #Delete storage server && property
    run delete_storage_server
}
