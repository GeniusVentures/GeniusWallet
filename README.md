# GeniusWallet

A new Flutter project.


This generates the dart files for rpc to Genius contracts in GeniusWallet

protoc --proto_path=../thirdparty/grpc/third_party/googleapis/ --proto_path=../pay-channel-eth/contracts/lib/data/proto/ --dart_out=json-./lib/GeniusContract/ ../pay-channel-eth/contracts/lib/data/proto/chain.proto
protoc --proto_path=../thirdparty/grpc/third_party/googleapis/ --proto_path=../pay-channel-eth/contracts/lib/data/proto/ --dart_out=./lib/GeniusContract/ ../pay-channel-eth/contracts/lib/data/proto/entity.proto



