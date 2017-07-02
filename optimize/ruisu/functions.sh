needRoot(){
    if (($EUID != 0));then
        echo "Need root privilege!"
        exit 1
    fi
}

message(){
    if (($# != 1));then
        echo "usage: message <msg>"
        return
    fi

    echo "--------------------------------------------------------"
    echo "-"
    echo "-   $1"
    echo "-"
    echo "--------------------------------------------------------"
}
