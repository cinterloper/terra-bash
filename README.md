```
g@g-skull:~/code/terra-bash$ docker run -t -i -v $(pwd):$(pwd) cinterloper/lash bash
root@ea295f761f62:/# apt install bash-builtins
...
root@ea295f761f62:/home/g/code/terra-bash# terra bash_builtin.t 
root@ea295f761f62:/home/g/code/terra-bash# enable -f ./hello.so hello
root@ea295f761f62:/home/g/code/terra-bash# hello
Hello, Terra!
root@ea295f761f62:/home/g/code/terra-bash# 
```
