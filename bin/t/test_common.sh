function contains()
{
    STRING=$1
    FILE=$2

    grep "$STRING" $FILE >> contains.log
    # found
    if [ $? -eq 0 ]; then
	# 0
	return ${SHUNIT_TRUE}
    # not found
    elif [ $? -eq 1 ]; then
	# 1
	return ${SHUNIT_FALSE}
    # error
    else
	# 2
	return ${SHUNIT_ERROR}
    fi
}

