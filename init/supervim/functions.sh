#!/bin/bash
usage(){
    echo "usage: $(basename $0) install [vim|nvim] [socks5 proxy]"
    echo "       $(basename $0) uninstall [vim|nvim]" 
    echo "       $(basename $0) installYcm [vim|nvim]"
    echo "       $(basename $0) installVimGo"
    echo "       $(basename $0) installFont"
    echo "       $(basename $0) update  (for update vimrc or init.vim)"
    exit 1
}

needCmd(){
    cmd=${1:?"Missing command name"}
    # fatal=${2:-"fatal"}
    echo -n "Check for $cmd ..."
    if ! command -v "$cmd" >/dev/null 2>&1;then
        echo -e "\t\t<Error: no found $cmd,failed!>" >&2
        # if [[ "$fatal" == "fatal" ]];then
        exit 1
        # fi
    else
        echo -e "\t\t[OK]"
    fi
}

msg(){
    echo "-----------------------------------------------------"
    echo "-"
    echo -e "- $1"
    echo "-"
    echo "-----------------------------------------------------"
}

installDependence(){
    #arch
    if command -v pacman >/dev/null 2>&1;then
        archApps="linux-headers clang neovim vim cmake python boost python-pip go go-tools fontconfig ctags "
        sudo pacman -Syu --noconfirm
        for tool in ${archApps};do
            sudo pacman -S $tool --noconfirm --needed
        done
    fi

    #fedora
    if command -v dnf >/dev/null 2>&1;then
        fedoraApps="kernel-devel vim clang python-devel python-pip python3-devel python3-pip cmake golang golang-godoc boost-devel ncurses-devel "
        sudo dnf update -y
        sudo dnf groupinstall "development tools" -y
        for tool in ${fedoraApps};do
            sudo dnf install $tool -y
        done
    fi

    #ubuntu
    if command -v apt-get >/dev/null 2>&1;then
        ubuntuApps="build-essential linux-headers-generic vim vim-gtk cmake clang python-apt python-dev python-pip python3-dev python3-pip libboost-all-dev golang golang-golang-x-tools ncurses-dev "
        sudo apt-get update -y
        for tool in ${ubuntuApps};do
            sudo apt-get install $tool -y
        done
    fi
}

#安装airline需要用的字体
installFont(){
    case $(uname) in
        "Linux")
            if fc-list | grep -iq Powerline;then
                return
            fi

            if [ ! -d ~/.local/share/fonts ];then
                mkdir -pv ~/.local/share/fonts
            fi
            cp ./fonts/PowerlineSymbols.otf ~/.local/share/fonts
            cp ./fonts/Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete.otf ~/.local/share/fonts
            fc-cache -vf ~/.local/share/fonts

            if [ ! -d ~/.config/fontconfig/conf.d ];then
                mkdir -pv ~/.config/fontconfig/conf.d
            fi
            cp ./fonts/10-powerline-symbols.conf ~/.config/fontconfig/conf.d
            ;;
        "Darwin")
            ALL_PROXY=socks5://127.0.0.1:1080 brew tap caskroom/fonts
            ALL_PROXY=socks5://127.0.0.1:1080 brew cask install font-hack-nerd-font
            echo "set Knack nerd font in iterm"

            ;;
        MINGW32*)
            echo "Please install nerd font manually."
            ;;
        *)
            echo "Unknown OS,install font failed!" >& 2
            ;;
    esac
}

updateCfg(){
    read -p "Update cfg file for which? (vim/nvim)" vim
    #不同得vim不同的路径
    if [[ "$vim" == "nvim" ]];then
        cfgFile="$HOME/.config/nvim/init.vim"
    elif [[ "$vim" == "vim" ]];then
        cfgFile="$HOME/.vimrc"
    else
        echo "Valid input is vim or nvim!" >&2
        exit 1
    fi
    cp ./init.vim $cfgFile
    $vim +PlugInstall +qall
}

#ycm for golang clang
installYcm(){
    vim=${1:?"install ycm for vim or nvim?"}
    if [[ "$vim" == "vim" ]];then
        dest="$HOME/.vim/plugins/YouCompleteMe"
    elif [[ "$vim" == "nvim" ]];then
        dest="$HOME/.config/nvim/plugins/YouCompleteMe"
    else
        echo "Valid input is vim or nvim!" >&2
        exit 1
    fi
    if [ -d "$dest" ];then
        cd "$dest"
        option=
        read -p "Ycm for clang(cpp)? [Y/n]" -t 5 clang
        if [[ "$clang" != [nN] ]];then
            option+=" --clang-completer "
            option+=" --system-libclang "
        fi
        read -p "Ycm for golang? [Y/n]" -t 5 golang
        if [[ "$golang" != [nN] ]];then
            option+=" --gocode-completer "
        fi

        #./install.py  --gocode-completer --clang-completer --system-libclang 
        eval ./install.py  "$option"
    fi
}

install(){
    needCmd curl
    #installDependence
    #安装vim还是nvim
    if (($#==0));then
        read -p "Install plugin for which? (vim/nvim)" vim
    else
        vim=$1
    fi
    if [[ "$vim" != "vim" && "$vim" != "nvim" ]];then
        echo "Unkown input '$vim',input vim or nvim!!">&2
        exit 1
    fi
    proxy=${2}
    installFont
    #不同的vim不同的路径
    if [[ "$vim" == "nvim" ]];then
        needCmd pip
        needCmd nvim
        destdir="$HOME/.config/nvim"
        cfgFile="$destdir/init.vim"
    elif [[ "$vim" == "vim" ]];then
        needCmd vim
        destdir="$HOME/.vim"
        version=$(\vim --version | grep -Po '(?<=Vi IMproved )\d+\.\d+')
        echo "vim version is ${version}"
        if (( $(echo "$version>=7.4" | bc -l) )) ;then
            #vim 7.4以后，vimrc文件可以放到.vim目录中
            cfgFile="$destdir/vimrc"
        else
            cfgFile="$HOME/.vimrc"
        fi
    fi

    uninstall $vim
    mkdir -pv $destdir/autoload
    mkdir -pv $destdir/plugins

    #copy color scheme
    cp -r ./colors $destdir
    #copy ftplugin
    cp -r ./ftplugin $destdir

    msg  "Downloading vim-plug from github..."
    if [ -n "$proxy" ];then
	echo "use proxy5:$proxy"
        curl --socks5 "$proxy" -fLo $destdir/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    else
        curl -fLo $destdir/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    # if netstat -tan|grep :::1080;then
    #     curl --socks5 127.0.0.1:1080 -fLo $destdir/autoload/plug.vim --create-dirs \
    #         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # else
    #     curl -fLo $destdir/autoload/plug.vim --create-dirs \
    #         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # fi

    if [[ "$vim" == "nvim" ]];then
        sudo -H -E pip install --upgrade pip
        sudo -H -E pip install --upgrade neovim
        # if netstat -tan|grep :8118;then
        #     sudo -H pip --proxy 127.0.0.1:8118 install --upgrade pip
        #     sudo -H pip --proxy 127.0.0.1:8118 install --upgrade neovim
        # else
        #     sudo -H pip install --upgrade pip
        #     sudo -H pip install --upgrade neovim
        # fi
    fi

    cp -v ./init.vim $cfgFile

    $vim +PlugInstall +qall
    # read -p "Install YouCompleteMe?(y/n): " -t 5 installycm
    # if [[ "$installycm" =~ [nN] ]];then
    #     #comment ycm
    #     sed -ibak "s/Plug 'Valloric\/YouCompleteMe'/\"&/" $cfgFile
    #     \rm "${cfgFile}bak"
    # fi

    # read -p "Install vim-go? [y/n]" -t 5 vimGo
    # if [[ "$vimGo" =~ [nN] ]];then
    #     sed -ibak "s+Plug 'fatih/vim-go'+\"&+" $cfgFile
    #     \rm "${cfgFile}bak"
    # fi

    # export GOPATH=~/Documents/go
    # $vim +PlugInstall +qall

    # if [[ "$vimGo" != [nN] ]];then
    #     $vim +GoInstallBinaries +qall
    # fi
    # #install YouCompleteMe
    # if [[ "$installycm" != [nN] ]];then
    #     installYcm $vim
    # fi
}

uninstall(){
    vim=${1:?"uninstall vim or nvim?"}
    if [[ "$vim" == "nvim" ]];then
        rm -rf ~/.config/nvim >/dev/null 2>&1
    elif [[ "$vim" == "vim" ]];then
        rm -rf ~/.vim >/dev/null 2>&1
        rm ~/.vimrc >/dev/null 2>&1
    fi
}

installVimGo(){
    read -p "Install vimGo for which? (vim/nvim)" vim
    #不同得vim不同的路径
    if [[ "$vim" == "nvim" ]];then
        destdir="$HOME/.config/nvim"
        cfgFile="$destdir/init.vim"
    elif [[ "$vim" == "vim" ]];then
        destdir="$HOME/.vim"
        cfgFile="$HOME/.vimrc"
    else
        echo "valid input is vim or nvim!" >&2
        exit 1
    fi
    sed -ibak "s|\"[ ]*\(Plug 'fatih/vim-go'\)|\1|" $cfgFile
    \rm "${cfgFile}bak"
    export GOPATH=~/go

    $vim PlugInstall +qall
    $vim GoInstallBinaries +qall
}

proxyOn(){
    # if command -v ss-client >/dev/null 2>&1;then
    #     ss-client globalStart
    #     port=8118
    #     if netstat -tan |grep LISTEN|grep -q "$port";then
    #         export http_proxy="127.0.0.1:$port"
    #         export HTTP_PROXY="$http_proxy"
    #         export https_proxy="$http_proxy"
    #         export HTTPS_PROXY="$http_proxy"
    #     fi
    # else
    #     echo "No proxy is used."
    # fi
    defaultProxy=${1}
    git config --global http.proxy "$defaultProxy"
    git config --global https.proxy "$defaultProxy"
}

