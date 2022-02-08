# KLEE VM

A simple Vagrantfile and provisioning script for building and experimenting with KLEE symbolic execution engine.

Starting up the vagrant vm should provision everything so that the klee binary is ready to use on login

```sh
vagrant up
vagrant ssh
```


## Resources

- [Building KLEE with LLVM9](https://klee.github.io/build-llvm9/)
- [KLEE Github Repo](https://github.com/klee/klee)
- [Building STP 2.3.3 for KLEE](https://klee.github.io/build-stp/)
- [STP Github Repo](https://github.com/stp/stp)

## Notes

The automatic install commands do not symlink binaries and libraries by default, so this behavior needs to be added explicitly. See `provision.sh` and `provision-stp.sh` for full installation process.