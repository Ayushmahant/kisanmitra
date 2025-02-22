import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class BlockchainService {
  final String rpcUrl = "http://127.0.0.1:8545"; // Local Hardhat Network
  final String contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  final String privateKey = "0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e";

  late Web3Client ethClient;
  late Credentials credentials;
  late DeployedContract contract;

  BlockchainService() {
    ethClient = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<String> getMessage() async {
    final contractAbi = "YOUR_CONTRACT_ABI";
    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, "SimpleContract"),
      EthereumAddress.fromHex(contractAddress),
    );
    final messageFunction = contract.function("message");
    final result = await ethClient.call(
      contract: contract,
      function: messageFunction,
      params: [],
    );
    return result.first.toString();
  }

  Future<String> updateMessage(String newMessage) async {
    final contractAbi = "YOUR_CONTRACT_ABI";
    final contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, "SimpleContract"),
      EthereumAddress.fromHex(contractAddress),
    );
    final updateFunction = contract.function("updateMessage");
    final txHash = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: updateFunction,
        parameters: [newMessage],
      ),
    );
    return txHash;
  }
}
