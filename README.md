RISC-V Labs
===========

# `main.sh` Usage

```bash

# default riscv64-linux-gnu-* toolchain
./main.sh

# override default toolchain
CC=gcc AS=as LD=ld GDB=gdb ./main.sh

```

# `tmux_gdb.sh` Usage

```bash

./tmux_gdb.sh -q -ex 'set debuginfod enabled off' -ex 'b hello_add::main' -ex 'r' ./bin/hello_add

```

# References

- https://mth.st/blog/riscv-qemu/
- https://twilco.github.io/riscv-from-scratch/2019/03/10/riscv-from-scratch-1.html
- https://twilco.github.io/riscv-from-scratch/2019/04/27/riscv-from-scratch-2.html
- https://twilco.github.io/riscv-from-scratch/2019/07/08/riscv-from-scratch-3.html
- https://twilco.github.io/riscv-from-scratch/2019/07/28/riscv-from-scratch-4.html
