import 'package:flutter/material.dart';

class LiveChatScreen extends StatefulWidget {
  final String orderId;
  const LiveChatScreen({Key? key, this.orderId = '#QB1024'}) : super(key: key);

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'manager', 'text': 'Hello! Thanks for ordering from Khoaaoo_jiii. Your food is being freshly prepared.'},
    {'sender': 'customer', 'text': 'Great! Please make sure it is extra spicy.'},
    {'sender': 'manager', 'text': 'Noted! Chef has been instructed accordingly.'},
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'customer', 'text': _msgController.text.trim()});
      _msgController.clear();
    });

    // Simulate automatic manager reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add({'sender': 'manager', 'text': 'Got it! Our rider will deliver it hot and fresh.'});
      });
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.restaurant, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Restaurant Manager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Order ${widget.orderId} • Online', style: const TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isCustomer = msg['sender'] == 'customer';
                return Align(
                  alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isCustomer ? Colors.deepOrange : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(color: isCustomer ? Colors.white : Colors.black87, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type your message to manager...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
