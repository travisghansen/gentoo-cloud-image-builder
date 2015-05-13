#!/bin/bash

## Basic Variables
SCRIPT_NAME=`basename $0`
SCRIPT_DIR=$(cd `dirname $0`;pwd);
SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_NAME}"
CALLED_AS=$0
CALLED_AS_FULL="$0 $@"
START_PWD=`pwd`
TOTAL_POSITIONAL_PARAMETERS=$#
FULL_POSITIONAL_PARAMETER_STRING=$@
TOTAL_PARAMETERS=0
TOTAL_OPTIONS=0

## Configuration
#MIN_OPTIONS=1
#MAX_OPTIONS=10
#MIN_PARAMETERS=1
#MAX_PARAMETERS=1

usage(){
	echo "Usage: " "${SCRIPT_NAME} -t [build|test]";
}

echo_exec_info(){
	echo "Script name: ${SCRIPT_NAME}"
	echo "Script directory: ${SCRIPT_DIR}"
	echo "Script path: ${SCRIPT_PATH}"
	echo "Called as: ${CALLED_AS}"
	echo "Called as full: ${CALLED_AS_FULL}"
	echo "Called from: ${START_PWD}"
	echo "Total options: ${TOTAL_OPTIONS}"
	echo "Total parameters: ${TOTAL_PARAMETERS}"
	echo "Total positional parameters: ${TOTAL_POSITIONAL_PARAMETERS}"
	echo "Full options/parameter string: ${FULL_POSITIONAL_PARAMETER_STRING}"
}

parameter_validation(){
	if [ -n "${MIN_OPTIONS}" ] && [ ${TOTAL_OPTIONS} -lt ${MIN_OPTIONS} ];then
		echo "Not enough options"
		usage
		exit 1
	fi

	if [ -n "${MIN_PARAMETERS}" ] && [ ${TOTAL_PARAMETERS} -lt ${MIN_PARAMETERS} ];then
		echo "Not enough parameters"
		usage
		exit 1
	fi

	if [ -n "${MAX_OPTIONS}" ] && [ ${TOTAL_OPTIONS} -gt ${MAX_OPTIONS} ];then
		echo "Too many options"
		usage
		exit 1
	fi

	if [ -n "${MAX_PARAMETERS}" ] && [ ${TOTAL_PARAMETERS} -gt ${MAX_PARAMETERS} ];then
		echo "Too many parameters"
		usage
		exit 1
	fi
}


main(){

    if [ "x${launch_type}" == "xbuild" ];then
        opts="-boot d"
    elif [ "x${launch_type}" == "xtest" ];then
        opts="-snapshot"
    else
        usage
        exit 1
    fi

    source config.sh
    ./isogen.sh 

    qemu-system-x86_64 \
        -enable-kvm -m 4096 -smp $(nproc) \
        -drive file=gentoo.img,if=virtio,index=0 \
        -cdrom "iso/${ISO}" \
        -drive file="iso/builder.iso",media=cdrom \
        -drive file="iso/config.iso",media=cdrom \
        -net nic,model=virtio -net user -vga cirrus -cpu host \
        -chardev file,id=charserial0,path=log/console.log \
        -device isa-serial,chardev=charserial0,id=serial0 \
        -chardev pty,id=charserial1 \
        -device isa-serial,chardev=charserial1,id=serial1 \
        ${opts}

}

#Parse options/parameters
while [ "$1" != "" ]; do
	#Options should always come first before parameters
	if [ "${1:0:1}" = "-" ];then
		TOTAL_OPTIONS=$(($TOTAL_OPTIONS + 1))
		case $1 in
			-t | --type )			shift
									launch_type=$1
									;;
			-i | --interactive )	interactive=1
									;;
			-h | --help )			usage
									exit
									;;
			* )						echo "Invalid option: " ${1}
									usage
									exit 1
		esac
	#Parameters always at the end
	else
		TOTAL_PARAMETERS=$#
		#FILE=$1
		#FILE2=$3
		#...
		#Clean them all up if desired
		while [ "$1" != "" ]; do
			shift;
		done
		break;
	fi
	shift
done


#echo_exec_info
parameter_validation
main


