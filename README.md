```
g@g-skull:~/code/terra-bash$ docker run -t -i -v $(pwd):$(pwd) cinterloper/lash bash
root@ea295f761f62:/# apt install bash-builtins
...
root@2f4916e38c1b:/home/g/code/terra-bash# /opt/terra-Linux-x86_64-332a506/bin/terra bash_builtin.t 
root@2f4916e38c1b:/home/g/code/terra-bash# enable -f ./hello-mt.so hello
root@2f4916e38c1b:/home/g/code/terra-bash# hello
new terra 1
hello terra/lua!
root@ea295f761f62:/home/g/code/terra-bash# 
```
