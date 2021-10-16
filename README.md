# GeniusWallet

GeniusWallet Parabeac/Flutter generated walletA new Flutter project.


## Setup Parabeac

cd ../thirdparty/Parabeac-core
git fetch upstream
git checkout upstream dev
git submodule init
git submodule update
pub get

## Run code generator
pushd ../thirdparty/Parabeac-Core
dart parabeac.dart -f Kqa6zYh2Qk1oTkWQtC1ueP -k 251430-45702049-022d-4e3f-b049-33633ec1f3e1 -o ../../ -n geniuswallet  
popd
