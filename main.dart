import 'package:flutter/material.dart';

void main() {
  runApp(const EasypayCloneApp());
}

/// Root of the app
class EasypayCloneApp extends StatefulWidget {
  const EasypayCloneApp({super.key});

  @override
  State<EasypayCloneApp> createState() => _EasypayCloneAppState();
}

class _EasypayCloneAppState extends State<EasypayCloneApp> {
  String? _loggedInEmail;

  void _handleLogin(String email) {
    setState(() {
      _loggedInEmail = email;
    });
  }

  void _handleLogout() {
    setState(() {
      _loggedInEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easypay Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: _loggedInEmail == null
          ? AuthPage(onLoggedIn: _handleLogin)
          : MainHomePage(
              email: _loggedInEmail!,
              onLogout: _handleLogout,
            ),
    );
  }
}

/// Simple email/password login (offline demo)
class AuthPage extends StatefulWidget {
  final void Function(String email) onLoggedIn;

  const AuthPage({super.key, required this.onLoggedIn});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Fake delay to feel like real auth
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    widget.onLoggedIn(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Easypay Clone'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 60),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Demo only – no real server/Firebase.\n'
                    'Use any email & password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple transaction model
class AppTransaction {
  final String type; // 'send' or 'bill'
  final double amount;
  final String detail;
  final DateTime time;

  AppTransaction({
    required this.type,
    required this.amount,
    required this.detail,
    required this.time,
  });
}

/// Main app after login: bottom nav (Home, Transactions, Profile)
class MainHomePage extends StatefulWidget {
  final String email;
  final VoidCallback onLogout;

  const MainHomePage({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  double _balance = 5000.0;
  final List<AppTransaction> _transactions = [];

  void _addTransaction(AppTransaction tx) {
    setState(() {
      _transactions.insert(0, tx);
      _balance -= tx.amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        email: widget.email,
        balance: _balance,
        onAddTransaction: _addTransaction,
      ),
      TransactionsPage(transactions: _transactions),
      ProfilePage(
        email: widget.email,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_toggle_off),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Dashboard: balance + quick actions
class DashboardPage extends StatelessWidget {
  final String email;
  final double balance;
  final void Function(AppTransaction) onAddTransaction;

  const DashboardPage({
    super.key,
    required this.email,
    required this.balance,
    required this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Welcome,',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              email,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wallet Balance'),
                    const SizedBox(height: 8),
                    Text(
                      'PKR ${balance.toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.send,
                    label: 'Send Money',
                    onTap: () => _openSendDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.receipt_long,
                    label: 'Pay Bills',
                    onTap: () => _openBillDialog(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSendDialog(BuildContext context) {
    final amountController = TextEditingController();
    final receiverController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: receiverController,
              decoration: const InputDecoration(
                labelText: 'Receiver Phone / ID',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0.0;
              final receiver = receiverController.text.trim();

              if (amount <= 0 || receiver.isEmpty) return;

              onAddTransaction(
                AppTransaction(
                  type: 'send',
                  amount: amount,
                  detail: 'Sent to $receiver',
                  time: DateTime.now(),
                ),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Money sent (demo only)')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _openBillDialog(BuildContext context) {
    final amountController = TextEditingController();
    final billRefController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: billRefController,
              decoration: const InputDecoration(
                labelText: 'Bill Reference No.',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text.trim()) ?? 0.0;
              final billRef = billRefController.text.trim();

              if (amount <= 0 || billRef.isEmpty) return;

              onAddTransaction(
                AppTransaction(
                  type: 'bill',
                  amount: amount,
                  detail: 'Bill $billRef paid',
                  time: DateTime.now(),
                ),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bill paid (demo only)')),
              );
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }
}

/// Quick action card
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Transactions page
class TransactionsPage extends StatelessWidget {
  final List<AppTransaction> transactions;

  const TransactionsPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isDebit = tx.type == 'send' || tx.type == 'bill';

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        tx.type == 'send'
                            ? Icons.north_east
                            : tx.type == 'bill'
                                ? Icons.receipt_long
                                : Icons.swap_vert,
                      ),
                    ),
                    title: Text(
                      tx.type == 'send'
                          ? 'Money Sent'
                          : tx.type == 'bill'
                              ? 'Bill Payment'
                              : 'Transaction',
                    ),
                    subtitle: Text(
                      '${tx.detail}\n${tx.time.toLocal()}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      '${isDebit ? '-' : '+'} PKR ${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDebit ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Profile page
class ProfilePage extends StatelessWidget {
  final String email;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.person, size: 80),
              const SizedBox(height: 12),
              Text(
                email,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Demo user (no real backend)',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                subtitle:
                    const Text('Would be handled via Firebase in real app'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
