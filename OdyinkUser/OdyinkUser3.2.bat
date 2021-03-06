@echo off
::3.2
::初始化
    chcp 936 >nul
    title Odyink User
    color 07
    cd /d %~dp0
::检测
    :check
    ::检测配置
        if not exist Odyink\website.bat goto setOdyink
        cd Odyink\
    ::检测PowerShell
        echo 检测是否存在PowerShell
        if not exist %SystemRoot%\System32\WindowsPowerShell\v1.0\PowerShell.exe (
            echo 查找不到PowerShell
            goto exit
        )
    ::检测网络
        echo 检测网络中
        if exist index.html del index.html
        PowerShell wget https://www.kernel.org/index.html -outfile index.html >nul
        if exist index.html (
            if exist index.html del index.html
            goto get
        )
        echo 网络出错!
        goto exit
::看文章
    ::下载文件
        :get
        cls
        echo 正在下载列表请稍后...
        call website.bat
        if "%website:~-1%"==" " set website=%website:~0,-1%
        if exist index.html del index.html
        if exist ServerOK del ServerOK
        if exist Blog*.bat del Blog*.bat
        if exist exdoc.bat del exdoc.bat
        if exist Blog\*.txt del /f /s /q Blog\*.txt >nul
        PowerShell wget %website%/ServerOK -outfile ServerOK >nul
        if not exist ServerOK goto ServerError
        PowerShell wget %website%/BlogAnum.bat -outfile BlogAnum.bat >nul
        PowerShell wget %website%/Blognum.bat -outfile Blognum.bat >nul
        PowerShell wget %website%/Bloglist.bat -outfile Bloglist.bat >nul
        PowerShell wget %website%/Blogexist.bat -outfile Blogexist.bat >nul
        PowerShell wget %website%/Blogdel.bat -outfile Blogdel.bat >nul
        if not exist BlogAnum.bat goto ServerError
        if not exist Blognum.bat goto ServerError
        if not exist Bloglist.bat goto ServerError
        if not exist Blogdel.bat goto ServerError
        if not exist Blogexist.bat goto ServerError
        cls
    ::文章列表
        :VB
        cls
        call Bloglist.bat
        echo.
        echo.
        call Blognum.bat
        if "%Blognum:~-1%"==" " set Blognum=%Blognum:~0,-1%
        echo 目前有%Blognum%篇文章
        echo.
        echo r.刷新 q.退出
        set EBlognum=
        set /p EBlognum=文章序号：
        cls
        if "%EBlognum%"=="r" goto get
        if "%EBlognum%"=="q" goto exit
    ::预处理
        :NBBlog
        cls
        set NEBEB=
        if "%EBlognum:~-1%"==" " set EBlognum=%EBlognum:~0,-1%
        if exist Blog\*.txt del /f /s /q Blog\*.txt >nul
        cls
        ::下载文章
            echo 下载文章
            PowerShell wget %website%/Blog/"%EBlognum%.txt" -outfile Blog\%EBlognum%.txt >nul
            cls
        ::检测文章是否存在
            if not exist Blog\"%EBlognum%.txt" (
                echo 本文章不存在或网络出错
                echo 即将返回列表
                timeout /t 2 /nobreak >nul
                goto VB
            )
        ::显示文本内容
            type Blog\%EBlognum%.txt
            echo.
            echo.
            echo b.上一篇 q.返回列表 n.下一篇
            echo         r.刷新文章
            echo.
            :BlogconNE
            set Blogcon=
            set /p Blogcon=操作序号：
            if "%Blogcon%"=="b" goto backBlog
            if "%Blogcon%"=="n" goto nextBlog
            if "%Blogcon%"=="q" goto VB
            if "%Blogcon%"=="r" goto NBBlog
            echo 输入无效请重新输入
            echo.
            goto BlogconNE
        ::上一篇文章
            :backBlog
            set StartEBlognum=%EBlognum%
            cls
            echo 正在检索请稍后...
            :Back
            set /a EBlognum=%EBlognum%-1
            set /a AV=%StartEBlognum%-%EBlognum%
            call set NEBEB=%%NEB%EBlognum%%%
            if "%NEBEB%"=="E " goto NBBlog
            if %AV%==101 goto NBBlog
            goto Back
        ::下一篇文章
            :nextBlog
            set StartEBlognum=%EBlognum%
            cls
            echo 正在检索请稍后...
            :Next
            set /a EBlognum=%EBlognum%+1
            set /a AV=%EBlognum%-%StartEBlognum%
            call set NEBEB=%%NEB%EBlognum%%%
            if "%NEBEB%"=="E " goto NBBlog
            if %AV%==101 goto NBBlog
            goto Next
::配置Odyink
    :setOdyink
    echo 配置Odyink
    set /p website=域名或IP[/目录]：
    echo 正在配置Odyink...
    if "%website:~-1%"=="/" set website=%website:~0,-1%
    mkdir Odyink >nul
    mkdir Odyink\Blog >nul
    cd Odyink
    if exist Blog*.bat del Blog*.bat
    if exist Blog\*.txt del /f /s /q Blog\*.txt >nul
    echo set website=%website% >website.bat
    cd ..\
    cls
    echo 配置完毕
    timeout /t 2 /nobreak >nul
    cls
    goto check
::退出
    :ServerError
    echo 服务器出错
    :exit
    echo 正在退出Odyink...
    if exist index.html del index.html
    if exist Blog*.bat del Blog*.bat
    if exist Blog\*.txt del /f /s /q Blog\*.txt >nul
    timeout /t 2 /nobreak >nul
    exit