# 一个以颜色显示A股行业涨跌的VIM插件

先上图:

[![55dFl8.png](https://z3.ax1x.com/2021/10/26/55dFl8.png)](https://imgtu.com/i/55dFl8)

## 安装

*   将本项目clone到`~/.vim/plugin`下面即可。

OR

*   如果你有安装插件管理工具，比如， `vim-plug`， 可以加入以下行到你的`.vimrc`进行安装

<!---->

    Plug 'bujnlc8/vim-stock'

## 命令


* `:Ca + [disappear]`， 以随机色块显示行业涨跌，绿色表示跌，红色表示涨。可接收一个参数`disappear`:是否自动消失，1是，0否，默认0。

