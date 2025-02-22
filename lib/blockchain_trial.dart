import 'package:kisanmitra/blockchain_service.dart'
final blockchain = BlockchainService();
final message = await blockchain.getMessage();
print("Contract Message: $message");

final txHash = await blockchain.updateMessage("New Flutter Message");
print("Transaction Hash: $txHash");
