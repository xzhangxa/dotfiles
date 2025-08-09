# A few packages needed for kernel build and/or BPF related tools.

# for kernel itself
sudo apt install -y flex bison gawk libssl-dev libelf-dev debhelper libdw-dev

# for tools/bpf, tools/lib/bpf, BTF
sudo apt install -y binutils-dev libreadline-dev libcap-dev clang llvm pahole

# if use Ubuntu default kernel config
# ./scripts/config --disable SYSTEM_TRUSTED_KEYS
# ./scripts/config --disable SYSTEM_REVOCATION_KEYS
