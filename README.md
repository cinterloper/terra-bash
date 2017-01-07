```
g@unit01:~/code/terra-bash$ docker run -t -i -v $(pwd):$(pwd) cinterloper/lash bash -c "cd $PWD && bash"
root@5823fd45c42e:/home/g/code/terra-bash# apt install -y bash-builtins
```
...
```
root@5823fd45c42e:/home/g/code/terra-bash# terra terrabash.t

```
...
```
root@5823fd45c42e:/home/g/code/terra-bash# enable -f ./terrabash.so terrabash
root@5823fd45c42e:/home/g/code/terra-bash# type terrabash
terrabash is a shell builtin
root@5823fd45c42e:/home/g/code/terra-bash# apt install libsodium-dev
```
...
```
root@5823fd45c42e:/home/g/code/terra-bash# cat nu.t

print("hello")
local C = terralib.includec("sodium.h")
for i,k in pairs(C) do
  bash.call("echo","C." .. i)
end

```

```
root@5823fd45c42e:/home/g/code/terra-bash# terrabash load_tfile ./nu.t | head -n 40
made it past lua init
made it past terra init
made it past init_terrabash
made it past assert
made it past cmd asgnment
hello
C.__CONSTANT_CFSTRINGS__
C.crypto_box_curve25519xsalsa20poly1305_boxzerobytes
C.__pthread_internal_list
C.__WAIT_STATUS
C.__UINT_LEAST8_MAX__
C.crypto_pwhash_scryptsalsa208sha256_opslimit_interactive
C.lcong48
C.gnu_dev_minor
C.__unix
C.srand48
C._IO_FILE_plus
C.crypto_aead_aes256gcm_NPUBBYTES
C.crypto_secretbox_boxzerobytes
C.pthread_mutex_t
C.EXIT_SUCCESS
C.__GXX_RTTI
C.sodium_hex2bin
C.timeval
C.ecvt_r
C.crypto_sign_primitive
C.div
C.fd_mask
C.crypto_secretbox_xsalsa20poly1305_boxzerobytes
C.crypto_verify_16_BYTES
C.__codecvt_partial
C.flockfile
C.__LDBL_EPSILON__
C._IOS_INPUT
C._crypto_stream_chacha20_pick_best_implementation
C._G_IO_IO_FILE_VERSION
C.u_short
C.__SIZEOF_POINTER__
C.__SIZE_WIDTH__
C.crypto_stream_aes128ctr_beforenmbytes
```
