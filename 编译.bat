:: 构建静态内容
hugo -d ../damuwangs.github.io

:: 提交blogContent
git add .
git commit -m "blogContent %date%" 
git push origin main

:: 切换到damuwangs.github.io文件夹
cd ../damuwangs.github.io
git add .
git commit -m "damuwangs.github.io %date%" 
git push origin gh-pages

pause