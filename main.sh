root_path=$(dirname $(realpath $0))
root_name=$(basename $root_path)

CC=${CC:-riscv64-linux-gnu-gcc}
AS=${AS:-riscv64-linux-gnu-as}
LD=${LD:-riscv64-linux-gnu-ld}
GDB=${GDB:-riscv64-linux-gnu-gdb}

path_src=$root_path/src
path_bin=$root_path/bin
if [[ ! -d $path_bin ]]; then
    mkdir -p $path_bin
fi

file_dtb=$root_path/qemu-riscv64-virt.dtb
file_dts=$root_path/qemu-riscv64-virt.dts
file_lds=$root_path/qemu-riscv64-virt.lds

function color_ps3() {
    local prompt=${1:-'Select '}

    echo $'\e[32m'$prompt$'\e[m'
}

function color_msg() {
    local color=${1:?'(r)ed or (g)reen (b)lue (y)ellow (p)urple (c)yan'}

    if (( 2 > $# )); then
        return
    fi

    if [[ 'r' == $color ]]; then
        echo -e '\e[31m'${@:2}'\e[0m' # red
    elif [[ 'g' == $color ]]; then
        echo -e '\e[32m'${@:2}'\e[0m' # green
    elif [[ 'b' == $color ]]; then
        echo -e '\e[34m'${@:2}'\e[0m' # blue
    elif [[ 'y' == $color ]]; then
        echo -e '\e[33m'${@:2}'\e[0m' # yellow
    elif [[ 'p' == $color ]]; then
        echo -e '\e[35m'${@:2}'\e[0m' # purple
    elif [[ 'c' == $color ]]; then
        echo -e '\e[36m'${@:2}'\e[0m' # cyan
    else
        echo -e '\e[37m'${@:2}'\e[0m' # white
    fi
}

function exec_command() {
    local cmd=${1:?'command to exec'}
    local ext_args=${2:-'y'}
    local cmd_args=(${@:3})

    if [[ 'y' == $ext_args ]]; then
        color_msg y "preparing execute: $cmd ${cmd_args[*]}"

        read -p "input $cmd ext args: " ext_cmd_args

        for ext_arg in ${ext_cmd_args[@]}; do
            cmd_args+=($ext_arg)
        done
    else
        cmd_args=(${@:1})
    fi

    color_msg g "executing: $cmd ${cmd_args[*]}"

    $cmd ${cmd_args[@]}

    return $?
}

function count_source_code() {
    local path_src=${1:?''}

    local source_codes=()

    for source_code in `find $path_src -maxdepth 1 -type f | grep -P '[^\s]+?\.(s|S|c|rs)$'`; do
        source_codes+=($source_code)
    done

    echo ${#source_codes[@]}
}

function select_source_code() {
    local path_src=${1:?''}

    local source_codes=()

    for source_code in `find $path_src -maxdepth 1 -type f | grep -P '[^\s]+?\.(s|S|c|rs)$'`; do
        source_codes+=($source_code)
    done

    PS3=`color_ps3 "select source code(1-${#source_codes[@]}): "`
    select source_code in "${source_codes[@]}"; do
        local index=$(($REPLY-1))
        if (( 0 > $index || $index >= ${#source_codes[@]} )); then
            index=0
        fi
        echo ${source_codes[$index]}
        break
    done
}

function compile_source_code() {
    local source_code=`select_source_code $path_src`

    local file_name=`basename -- $source_code`
    file_name=${file_name%.*}

    if (( 0 < `echo $source_code | grep -coP '[^\s]+?\.(s|S)$'` )); then
        exec_command $AS y -g -o $path_bin/$file_name.elf $source_code

        if [[ ! -f $file_lds ]]; then
            generate_lds
        fi
        exec_command $LD y -T $file_lds -o $path_bin/$file_name.linked.elf $path_bin/$file_name.elf
    elif (( 0 < `echo $source_code | grep -coP '[^\s]+?\.c$'` )); then
        exec_command $CC y -g -O0 -o $path_bin/$file_name $source_code
    elif (( 0 < `echo $source_code | grep -coP '[^\s]+?\.rs$'` )); then
        exec_command rustc y -g -o $path_bin/$file_name $source_code
    fi
}

function qemu_debug() {
    local source_code=`select_source_code $path_src`

    local file_name=`basename -- $source_code`
    file_name=${file_name%.*}

    color_msg y 'Abort: Ctrl + A, X'
    color_msg y 'Output:\n'

    qemu-system-riscv64 -machine virt -kernel $path_bin/$file_name.linked.elf -bios none -s -S -nographic
}

function gdb_debug() {
    local source_code=`select_source_code $path_src`

    local file_name=`basename -- $source_code`
    file_name=${file_name%.*}

    if (( 0 < `echo $source_code | grep -coP '[^\s]+?\.(s|S)$'` )); then
        GDB=$GDB $root_path/tmux_gdb.sh -q -ex 'target remote :1234' -ex 'b _start' -ex 'c' $path_bin/$file_name.linked.elf
    elif (( 0 < `echo $source_code | grep -coP '[^\s]+?\.c$'` )); then
        GDB=$GDB $root_path/tmux_gdb.sh -q -ex 'set debuginfod enabled off' -ex 'b main' -ex 'r' $path_bin/$file_name
    elif (( 0 < `echo $source_code | grep -coP '[^\s]+?\.rs$'` )); then
        GDB=$GDB $root_path/tmux_gdb.sh -q -ex 'set debuginfod enabled off' -ex "b $file_name::main" -ex 'r' $path_bin/$file_name
    fi
}

function qemu_run() {
    local source_code=`select_source_code $path_src`

    local file_name=`basename -- $source_code`
    file_name=${file_name%.*}

    color_msg y 'Abort: Ctrl + A, X'
    color_msg y 'Output:\n'

    qemu-system-riscv64 -machine virt -kernel $path_bin/$file_name.linked.elf -bios none -nographic
}

function convert_dtb2dts() {
    qemu-system-riscv64 -machine virt,dumpdtb=$file_dtb
    dtc -I dtb -O dts -f $file_dtb -o $file_dts
}

function generate_lds() {
    $LD --verbose > $file_lds
    local b=`cat $file_lds | grep -noP '^====' | grep -oP '\d+' | head -n 1`
    local e=`cat $file_lds | grep -noP '^====' | grep -oP '\d+' | tail -n 1`
cat <<EOF > $file_lds
`sed -n "$(($b+1)),$(($e-1))p" $file_lds`
MEMORY
{
  ram (rwxai) : ORIGIN = 0x80000000, LENGTH = 0x8000000
}
EOF
}

function clean_all() {
    rm -rf $root_path/bin
    rm -rf $file_dtb $file_dts $file_lds
}

function main() {
    local titles=(
        "compile source code(`count_source_code $path_src`)"
        "qemu debug"
        "gdb debug"
        "qemu run"
        "generate lds"
        "convert dtb to dts"
        "clean all"
    )

    local actions=(
        'compile_source_code'
        'qemu_debug'
        "gdb_debug"
        'qemu_run'
        'generate_lds'
        'convert_dtb2dts'
        'clean_all'
    )

    PS3=`color_ps3 "select cargo command(1-${#actions[@]}): "`
    select title in "${titles[@]}"; do
        local index=$(($REPLY-1))
        if (( 0 > $index || $index >= ${#actions[@]} )); then
            index=0
        fi
        ${actions[$index]}
        break
    done
}
main
