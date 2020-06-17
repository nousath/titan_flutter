import 'package:titan/config.dart';
import 'package:titan/src/plugins/wallet/contract_const.dart';

import '../../../env.dart';

class TokenUnit {
  static const WEI = 1;
  static const K_WEI = 1000;
  static const M_WEI = 1000000;
  static const G_WEI = 1000000000;
  static const T_WEI = 1000000000000;
  static const P_WEI = 1000000000000000;
  static const ETHER = 1000000000000000000;
}

class EthereumConst {
  static const LOW_SPEED = 15 * TokenUnit.G_WEI;
  static const FAST_SPEED = 30 * TokenUnit.G_WEI;
  static const SUPER_FAST_SPEED = 60 * TokenUnit.G_WEI;

  static const int ETH_TRANSFER_GAS_LIMIT = 21000;
  static const int ERC20_TRANSFER_GAS_LIMIT = 65000;

  static const int ERC20_APPROVE_GAS_LIMIT = 50000;

  static const int CREATE_MAP3_NODE_GAS_LIMIT = 560000;
  static const int DELEGATE_MAP3_NODE_GAS_LIMIT = 700000;

  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_81 = 2800000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_61 = 2100000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_41 = 1500000;
  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT_21 = 800000;

  static const int COLLECT_MAP3_NODE_CREATOR_GAS_LIMIT = 800000;

  static const int COLLECT_MAP3_NODE_PARTNER_GAS_LIMIT = 80000;
  static const int COLLECT_HALF_MAP3_NODE_GAS_LIMIT = 150000;
}

class BitcoinConst{
  static const BTC_LOW_SPEED = 15;
  static const BTC_FAST_SPEED = 30;
  static const BTC_SUPER_FAST_SPEED = 60;
  static const BTC_RAWTX_SIZE = 225;
}

class WalletError {
  static const UNKNOWN_ERROR = "0";
  static const PASSWORD_WRONG = "1";
  static const PARAMETERS_WRONG = "2";
}

enum EthereumNetType {
  main,
  ropsten,
  rinkeby,
  local,
}

enum BitcoinNetType {
  main,
  local,
}

EthereumNetType getEthereumNetTypeFromString(String type) {
  for (var value in EthereumNetType.values) {
    if (value.toString() == type) {
      return value;
    }
  }
  return EthereumNetType.main;
}

class WalletConfig {
  static String get INFURA_MAIN_API => '${Config.INFURA_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_ROPSTEN_API => '${Config.INFURA_ROPSTEN_API_URL}/v3/${Config.INFURA_PRVKEY}';

  static String get INFURA_RINKEBY_API => 'https://rinkeby.infura.io/v3/${Config.INFURA_PRVKEY}';

  static String get BITCOIN_MAIN_API => 'https://host/wallet/btc/';

  static String get BITCOIN_LOCAL_API => 'http://10.10.1.113/wallet/btc/';

  static EthereumNetType netType = env.buildType == BuildType.DEV ? EthereumNetType.ropsten : EthereumNetType.main;

  static BitcoinNetType bitcoinNetType = env.buildType == BuildType.DEV ? BitcoinNetType.local : BitcoinNetType.main;

  static String get map3ContractAddress {
    switch (netType) {
      case EthereumNetType.main:
        return '0x04dd43162ccb7c2e256128e28e29218c5057e7f3';
      case EthereumNetType.ropsten:
        return '0x2c6FA17BDF5Cb10e64d26bFc62f64183D9f939A6';
      case EthereumNetType.rinkeby:
        return '0x02061f896Da00fC459C05a6f864b479137Dcb34b';
      case EthereumNetType.local:
        return ContractTestConfig.map3ContractAddress;
      //return '0x14D135f91B01db0DF32cdcF7d7e93cc14A9aE3D7';
    }
    return '';
  }

  static String getEthereumApi() {
    switch (netType) {
      case EthereumNetType.main:
        return INFURA_MAIN_API;
      case EthereumNetType.ropsten:
        return INFURA_ROPSTEN_API;
      case EthereumNetType.rinkeby:
        return INFURA_RINKEBY_API;
      case EthereumNetType.local:
        return ContractTestConfig.walletLocalDomain;
      //return LOCAL_API;
    }
    return '';
  }

  static String getBitcoinApi() {
    switch (bitcoinNetType) {
      case BitcoinNetType.main:
        return BITCOIN_MAIN_API;
      case BitcoinNetType.local:
        return BITCOIN_LOCAL_API;
    //return LOCAL_API;
    }
    return '';
  }
}
