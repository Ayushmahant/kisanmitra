import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Web3Helper {
  final String rpcUrl = "http://127.0.0.1:8545"; // Hardhat local node
  final String privateKey = "0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e"; // Use Hardhat account private key

  late Web3Client client;
  late Credentials credentials;
  late DeployedContract contract;

  Web3Helper() {
    client = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> loadContract() async {
    String abi = '''[
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "itemId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "name",
          "type": "string"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "quantity",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "string",
          "name": "imageUrl",
          "type": "string"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "seller",
          "type": "address"
        }
      ],
      "name": "ItemAdded",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "_name",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "_quantity",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "_imageUrl",
          "type": "string"
        }
      ],
      "name": "addAuctionItem",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "name": "auctionItems",
      "outputs": [
        {
          "internalType": "string",
          "name": "name",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "quantity",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "imageUrl",
          "type": "string"
        },
        {
          "internalType": "address",
          "name": "seller",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getAllAuctionItems",
      "outputs": [
        {
          "components": [
            {
              "internalType": "string",
              "name": "name",
              "type": "string"
            },
            {
              "internalType": "uint256",
              "name": "quantity",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "imageUrl",
              "type": "string"
            },
            {
              "internalType": "address",
              "name": "seller",
              "type": "address"
            }
          ],
          "internalType": "struct SimpleContract.Item[]",
          "name": "",
          "type": "tuple[]"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "index",
          "type": "uint256"
        }
      ],
      "name": "getAuctionItem",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        },
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        },
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]'''; // Paste ABI here
    EthereumAddress contractAddress = EthereumAddress.fromHex("0x5FbDB2315678afecb367f032d93F642f64180aa3");
    contract = DeployedContract(ContractAbi.fromJson(abi, "Auction"), contractAddress);
  }

  Future<String> addAuctionItem(String name, int quantity, String imageUrl) async {
    final function = contract.function("addAuctionItem");
    final result = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [name, BigInt.from(quantity), imageUrl],
      ),
    );
    return result;
  }
}
