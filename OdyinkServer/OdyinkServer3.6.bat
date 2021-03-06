@echo off
rem 3.6
rem 初始化
    chcp 936 >nul
    title Odyink Server
    color 07
    cd /d %~dp0
rem 检测安装
    :Check
    if not exist odyink\Bloglist.bat goto :install
    cd odyink\
rem 菜单
    :menu
    cls
    echo 1.校阅文章
    echo 2.导入文章
    echo 3.删除文章
    echo 4.退出程序
    echo.
    set Munum=
    set /p Munum=序号：
    cls
    if "%Munum%"=="1" goto :VB
    if "%Munum%"=="2" goto :cpBlog
    if "%Munum%"=="3" goto :DBlog
    if "%Munum%"=="4" exit
    echo 输入无效
    timeout /t 2 /nobreak >nul
    goto :menu
rem 校阅文章
    rem 文章列表
        :VB
        cls
        call Bloglist.bat
        echo.
        echo.
        call Blognum.bat
        if "%Blognum:~-1%"==" " set Blognum=%Blognum:~0,-1%
        echo 目前有%Blognum%篇文章
        echo.
        echo q.返回主页
        set EBlognum=
        set /p EBlognum=文章序号：
        cls
        if /i "%EBlognum%"=="q" goto :menu
    rem 预处理
        :NBBlog
        set Doctype=
    rem 检测文章是否存在
        if not exist Blog\"%EBlognum%.bat" (
            if not exist Blog\"%EBlognum%.txt" (
                echo 文章不存在
                timeout /t 2 /nobreak >nul
                goto :VB
            )
        )
    rem 显示文本内容Batch
        if exist Blog\"%EBlognum%.bat" (
            set Doctype=bat
            echo 这是Batch扩展
            echo 可在odyink\Blog\%EBlognum%.bat中查看代码
            echo 因Batch扩展特殊性执行后果自负
            echo 查看代码是为了防病毒!!!
            set /p batrunyn=是否确认执行yn:
            if /i "%batrunyn%"=="y" goto :runbat
            goto :VB
            :runbat
            cls
            cmd /c .\Blog\%EBlognum%.bat
            cls
            rem 重新初始化
                rem 这里if复合句不能用@echo off会报错现移到:BlogconNE下一行
                rem 这里if复合句不用cd，它会自动恢复(原因不明)而且用cd会报错
                chcp 936 >nul
                title Odyink Server
                color 07
            echo b.上一篇 q.返回列表 n.下一篇
            echo          c.修改扩展
            goto :BlogconNE
        )
    rem 显示文本内容Text
        set Doctype=txt
        type Blog\%EBlognum%.txt
        echo.
        echo.
        echo b.上一篇 q.返回列表 n.下一篇
        echo          c.修改文章
        echo.
    rem 文章操作
        :BlogconNE
        @echo off
        set Blogcon=
        set /p Blogcon=操作序号：
        if /i "%Blogcon%"=="b" goto :backBlog
        if /i "%Blogcon%"=="n" goto :nextBlog
        if /i "%Blogcon%"=="q" goto :VB
        if /i "%Blogcon%"=="c" (
            notepad.exe .\Blog\%EBlognum%.%Doctype%
            cls
            goto :NBBlog
        )
        echo 输入无效
        echo.
        goto :BlogconNE
    rem 上一篇文章
        :backBlog
        set StartEBlognum=%EBlognum%
        cls
        :Back
        set /a EBlognum=%EBlognum%-1
        set /a AV=%StartEBlognum%-%EBlognum%
        rem 两文章间距不可大于100
        if %AV%==100 goto :NBBlog
        if %EBlognum%==-1 goto :NBBlog
        if exist Blog\%EBlognum%.bat goto :NBBlog
        if exist Blog\%EBlognum%.txt goto :NBBlog
        goto :Back
    rem 下一篇文章
        :nextBlog
        set StartEBlognum=%EBlognum%
        cls
        :Next
        set /a EBlognum=%EBlognum%+1
        set /a AV=%EBlognum%-%StartEBlognum%
        rem 两文章间距不可大于100
        if %AV%==100 goto :NBBlog
        if exist Blog\%EBlognum%.bat goto :NBBlog
        if exist Blog\%EBlognum%.txt goto :NBBlog
        goto :Next
rem 导入文章
    :cpBlog
    cls
    set Docname=
    set Blognum=
    set NewBlognum=
    set Blogtitle=
    set Doctype=
    rem 输入需导入文章的信息
        echo 支持GBK编码的txt和bat文件
        echo 支持拖放文件(不要手贱)
        echo q.返回
        echo.
        rem 以管理员身份运行无法拖动导入文章
        set /p Docname=文件绝对路径：
        if %Docname%==q goto :menu
        if not exist %Docname% goto :CantcpBlog
        if %Docname:~-4,-3%==. set Doctype=%Docname:~-3%
        if %Docname:~-5,-4%==. set Doctype=%Docname:~-4,-1%
        if not "%Doctype%"=="bat" (
            if not "%Doctype%"=="txt" (
                echo 文件不支持
                timeout /t 3 /nobreak >nul
                goto :cpBlog
            )
        )
        rem 文章标题不能含有英引号
        set /p Blogtitle=文章标题：
        if /i "%Blogtitle%"=="q" goto :cpBlog
    rem 开始导入文章
        cls
        rem 预处理
        call Blognum.bat
        if "%Blognum:~-1%"==" " set Blognum=%Blognum:~0,-1%
        set /a NewBlognum=%Blognum%+1
        call BlogAnum.bat
        if "%BlogAnum:~-1%"==" " set BlogAnum=%BlogAnum:~0,-1%
        set /a NewBlogAnum=%BlogAnum%+1
        rem 写入
        echo set Blognum=%NewBlognum% >Blognum.bat
        echo set BlogAnum=%NewBlogAnum% >BlogAnum.bat
        echo set NEB%NewBlogAnum%=E>>Blogexist.bat
        echo if not %%NEB%NewBlogAnum%%%==Del echo %NewBlogAnum%.%Blogtitle% >>Bloglist.bat
        echo %date:~0,-2%%time% copy %Docname% to .\odyink\Blog\ (num:%NewBlogAnum%) >>Bloglog.log
        if exist %Docname% copy %Docname% Blog\%NewBlogAnum%.%Doctype% >nul
        echo 导入完毕
        timeout /t 2 /nobreak >nul
        goto :cpBlog
    rem 文章不存在
        :CantcpBlog
        cls
        echo 文章不存在
        timeout /t 3 /nobreak >nul
        goto :cpBlog
rem 删除文章
    :DBlog
    cls
    set willDelBlog=
    set DelBlogyn=
    call Bloglist.bat
    call Blognum.bat
    rem 输入需删除文章的信息
        :DelBlog
        echo 输入q退出删除
        set /p willDelBlog=要删除文章序号：
        if /i "%willDelBlog%"=="q" goto :menu
        if not exist Blog\"%willDelBlog%.*t" goto :DelBlogE
        :BackDelyn
        set /p DelBlogyn=是否删除yn:
        if /i "%DelBlogyn%"=="y" goto :DelBlognow
        if /i "%DelBlogyn%"=="n" goto :DelBlog
        echo 输入无效
        goto :BackDelyn
    rem 开始删除文章
        :DelBlognow
        echo set NEB%willDelBlog%=Del >>Blogdel.bat
        set /a NewBlognum=%Blognum%-1
        echo set Blognum=%NewBlognum% >Blognum.bat
        echo %date:~0,-2%%time% del %willDelBlog% from .\odyink\Blog\ (num:%willDelBlog%) >>Bloglog.log
        del /q Blog\%willDelBlog%.*t
        echo 删除完毕
        timeout /t 2 /nobreak >nul
        cls
        goto :DBlog
    rem 文章不存在
        :DelBlogE
        echo 文章不存在
        goto :DelBlog
rem 安装
    :install
    echo 回车安装Odyink
    pause >nul
    cls
    mkdir odyink\Blog >nul
    cd Odyink
    if exist Blog\*.*t del /f /s /q Blog\*.*t >nul
    rem 新建文件写入信息
        echo set Blognum=1 >Blognum.bat
        echo set BlogAnum=0 >BlogAnum.bat
        echo set NEB0=E>>Blogexist.bat
        echo call Blogexist.bat >>Bloglist.bat
        echo call Blogdel.bat>>Bloglist.bat
        echo if not %%NEB0%%==Del echo 0.欢迎使用Odyink>>Bloglist.bat
        echo rem Blogdel>Blogdel.bat
        echo [Bloglog]>Bloglog.log
        echo Odyink是由Andy(python)和SMG(Batch)制作的命令行个人博客软件 >>Blog\0.txt
        cd ..\
        echo 安装完毕
        timeout /t 2 /nobreak >nul
        cls
        goto :Check