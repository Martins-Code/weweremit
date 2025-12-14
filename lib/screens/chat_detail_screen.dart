import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_theme.dart';
import '../widgets/app_drawer.dart';
import 'chat_list_screen.dart';
import '../models/dealer.dart';
import '../models/user_model.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  static const routeName = '/chat-detail';

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final TextEditingController _rateController = TextEditingController();

  ChatConversation? _conversation;
  UserRole? _userRole;

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final role = doc.data()?['role'] as String?;
          setState(() {
            if (role == 'admin') {
              _userRole = UserRole.admin;
            } else if (role == 'dealer') {
              _userRole = UserRole.dealer;
            } else {
              _userRole = UserRole.user;
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading user role: $e');
      }
    }
  }

  void _initializeMessages() {
    // Initialize with sample messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        text: 'Hello! I\'m interested in sending money to Nigeria.',
        isSent: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '2',
        text: 'Hi! Great to hear from you. I can help you with that. What amount are you looking to send?',
        isSent: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        text: 'I\'m planning to send around 2000 AUD.',
        isSent: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '4',
        text: 'Perfect! I can offer you a rate of 1 AUD = 950 NGN. This is one of the best rates available.',
        isSent: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '5',
        text: 'That sounds good! How long will the transfer take?',
        isSent: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '6',
        text: 'The transfer will be completed within 24 hours. Funds will be available in the recipient\'s account.',
        isSent: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        status: MessageStatus.read,
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _initializeMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ChatConversation) {
      _conversation = args;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _messageController.text.trim(),
          isSent: true,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      );
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: AppDrawer(
        currentRoute: ChatDetailScreen.routeName,
        onNavigate: (route) => _handleNavigation(context, route),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        title: _conversation != null
            ? Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.oceanTeal,
                              AppColors.primaryBlue,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _conversation!.avatar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      if (_conversation!.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.cardBackground,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _conversation!.merchantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _conversation!.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final showAvatar = index == 0 ||
                          _messages[index - 1].isSent != message.isSent;
                      
                      return _MessageBubble(
                        message: message,
                        showAvatar: showAvatar,
                        formatTime: _formatTime,
                      );
                    },
                  ),
          ),
          // Message input
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Rate offer button for dealers/admins
                  if (_userRole == UserRole.dealer || _userRole == UserRole.admin) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.oceanTeal,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showRateOfferDialog(context),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.attach_money_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    decoration: const BoxDecoration(
                      gradient: Gradients.button,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _sendMessage,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showRateOfferDialog(BuildContext context) {
    CurrencyDirection selectedDirection = CurrencyDirection.audToNgn;
    final TextEditingController amountController = TextEditingController();
    bool showRateInput = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Offer Custom Rate',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select currency direction:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<CurrencyDirection>(
                  segments: const [
                    ButtonSegment(
                      value: CurrencyDirection.audToNgn,
                      label: Text('AUD → NGN'),
                    ),
                    ButtonSegment(
                      value: CurrencyDirection.ngnToAud,
                      label: Text('NGN → AUD'),
                    ),
                  ],
                  selected: {selectedDirection},
                  onSelectionChanged: (Set<CurrencyDirection> newSelection) {
                    setDialogState(() {
                      selectedDirection = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (AUD)',
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      showRateInput = value.isNotEmpty && double.tryParse(value) != null;
                    });
                  },
                ),
                if (showRateInput) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedDirection == CurrencyDirection.audToNgn
                          ? 'Rate (NGN per AUD)'
                          : 'Rate (AUD per NGN)',
                      hintText: selectedDirection == CurrencyDirection.audToNgn
                          ? 'e.g., 950'
                          : 'e.g., 0.00105',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.percent),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final rate = double.tryParse(_rateController.text);
                
                if (amount != null && rate != null && rate > 0) {
                  final calculatedAmount = selectedDirection == CurrencyDirection.audToNgn
                      ? amount * rate
                      : amount * rate;
                  
                  final rateOffer = RateOffer(
                    rate: rate,
                    direction: selectedDirection,
                    amountAUD: selectedDirection == CurrencyDirection.audToNgn ? amount : calculatedAmount,
                    amountNGN: selectedDirection == CurrencyDirection.audToNgn ? calculatedAmount : amount,
                    isCustom: true,
                  );

                  // Add rate offer message
                  setState(() {
                    _messages.add(
                      ChatMessage(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        text: _buildRateOfferMessage(rateOffer),
                        isSent: true,
                        timestamp: DateTime.now(),
                        status: MessageStatus.sent,
                        rateOffer: rateOffer,
                      ),
                    );
                  });

                  Navigator.of(dialogContext).pop();
                  amountController.dispose();
                  _rateController.clear();
                  
                  // Scroll to bottom
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
              child: const Text('Send Offer'),
            ),
          ],
        ),
      ),
    );
  }

  String _buildRateOfferMessage(RateOffer offer) {
    if (offer.direction == CurrencyDirection.audToNgn) {
      return 'I can offer you a rate of ₦${offer.rate.toStringAsFixed(2)} per \$1 AUD. '
          'For \$${offer.amountAUD.toStringAsFixed(2)} AUD, you will receive ₦${offer.amountNGN.toStringAsFixed(2)} NGN.';
    } else {
      return 'I can offer you a rate of \$${offer.rate.toStringAsFixed(4)} per ₦1 NGN. '
          'For ₦${offer.amountNGN.toStringAsFixed(2)} NGN, you will receive \$${offer.amountAUD.toStringAsFixed(2)} AUD.';
    }
  }

  void _handleNavigation(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushNamed(route);
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isSent;
  final DateTime timestamp;
  final MessageStatus status;
  final RateOffer? rateOffer;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isSent,
    required this.timestamp,
    required this.status,
    this.rateOffer,
  });
}

class RateOffer {
  final double rate;
  final CurrencyDirection direction;
  final double amountAUD;
  final double amountNGN;
  final bool isCustom; // True if dealer offered custom rate to this user

  RateOffer({
    required this.rate,
    required this.direction,
    required this.amountAUD,
    required this.amountNGN,
    this.isCustom = false,
  });
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.formatTime,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isSent && showAvatar) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.oceanTeal,
                    AppColors.primaryBlue,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  'M',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSent
                        ? AppColors.primaryBlue
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(
                        message.isSent ? 20 : 4,
                      ),
                      bottomRight: Radius.circular(
                        message.isSent ? 4 : 20,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isSent
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      if (message.rateOffer != null) ...[
                        const SizedBox(height: 12),
                        _RateOfferCard(
                          offer: message.rateOffer!,
                          isSent: message.isSent,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                    if (message.isSent) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.status == MessageStatus.read
                            ? Icons.done_all
                            : message.status == MessageStatus.delivered
                                ? Icons.done_all
                                : Icons.done,
                        size: 14,
                        color: message.status == MessageStatus.read
                            ? AppColors.primaryBlue
                            : AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (message.isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _RateOfferCard extends StatelessWidget {
  const _RateOfferCard({
    required this.offer,
    required this.isSent,
  });

  final RateOffer offer;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: offer.isCustom
            ? Colors.green.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: offer.isCustom
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on_rounded,
                color: offer.isCustom ? Colors.green : AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                offer.isCustom ? 'Custom Rate Offer' : 'Rate Offer',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: offer.isCustom ? Colors.green : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.direction == CurrencyDirection.audToNgn
                        ? 'Amount (AUD)'
                        : 'Amount (NGN)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.direction == CurrencyDirection.audToNgn
                        ? '\$${offer.amountAUD.toStringAsFixed(2)}'
                        : '₦${offer.amountNGN.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    offer.direction == CurrencyDirection.audToNgn
                        ? 'You Receive (NGN)'
                        : 'You Receive (AUD)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.direction == CurrencyDirection.audToNgn
                        ? '₦${offer.amountNGN.toStringAsFixed(2)}'
                        : '\$${offer.amountAUD.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: offer.isCustom ? Colors.green : AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Rate: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  offer.direction == CurrencyDirection.audToNgn
                      ? '₦${offer.rate.toStringAsFixed(2)} per \$1'
                      : '\$${offer.rate.toStringAsFixed(4)} per ₦1',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          if (!isSent) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Decline offer
                    },
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      // Accept offer and proceed
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('Accept & Proceed'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
