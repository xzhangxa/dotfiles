# A few packages needed for kernel build and/or BPF related tools.

# for kernel itself
sudo apt install -y flex bison libssl-dev libelf-dev libncursesw5-dev debhelper

# for tools/bpf, tools/lib/bpf, BTF
sudo apt install -y binutils-dev libreadline-dev libcap-dev clang llvm pahole
