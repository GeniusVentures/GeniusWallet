

set -e

for i in "$@"
do
case $i in
  --thirdparty-out-dir=*)
    THIRDPARTY_DIR="${i#*=}"
    shift
    ;;
  --wrapper-src-dir=*)
    WRAPPER_SRC_DIR="${i#*=}"
    shift
    ;;
esac
done

mkdir -p .build
cd .build
cmake ../ -DWALLET_CORE_LIB_DIR=$THIRDPARTY_DIR -DPRJ_WRAPPER_DIR=$WRAPPER_SRC_DIR

make



