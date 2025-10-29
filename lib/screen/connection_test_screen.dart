import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';

/// Firebase & Supabase Connection Test Screen
/// Verifies that both backends are properly connected
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String firebaseStatus = 'Testing...';
  String firestoreStatus = 'Testing...';
  String supabaseStatus = 'Testing...';
  String authStatus = 'Not tested';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() => isLoading = true);

    // Test Firebase Core
    await _testFirebase();

    // Test Supabase Database (instead of Firestore)
    await _testSupabaseDatabase();

    // Test Supabase Connection
    await _testSupabase();

    setState(() => isLoading = false);
  }

  Future<void> _testFirebase() async {
    try {
      final app = Firebase.app();
      final projectId = app.options.projectId;
      setState(() {
        firebaseStatus = '✅ Connected\nProject: $projectId';
      });
    } catch (e) {
      setState(() {
        firebaseStatus = '❌ Failed: $e';
      });
    }
  }

  Future<void> _testSupabaseDatabase() async {
    if (!EnvConfig.useSupabase) {
      setState(() {
        firestoreStatus = '⚠️ Supabase disabled in config';
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Test database connection by checking eco_tips table
      await supabase
          .from('eco_tips')
          .select('count')
          .limit(1)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Database timeout. Run SQL schema in Supabase.');
            },
          );
      
      setState(() {
        firestoreStatus = '✅ Supabase DB Connected\nPostgreSQL Ready';
      });
    } catch (e) {
      final errorMsg = e.toString();
      setState(() {
        if (errorMsg.contains('timeout') || errorMsg.contains('relation') || errorMsg.contains('does not exist')) {
          firestoreStatus = '⚠️ Database tables not created\nRun supabase_schema.sql\nin Supabase SQL Editor';
        } else {
          firestoreStatus = '❌ DB Error: ${errorMsg.length > 80 ? '${errorMsg.substring(0, 80)}...' : errorMsg}';
        }
      });
    }
  }

  Future<void> _testSupabase() async {
    if (!EnvConfig.useSupabase) {
      setState(() {
        supabaseStatus = '⚠️ Disabled in config';
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      
      // Test connection by checking auth
      final isConnected = supabase.auth.currentSession != null;
      
      setState(() {
        supabaseStatus = '✅ Connected\nURL: ${EnvConfig.supabaseUrl.substring(0, 30)}...\nSession: ${isConnected ? "Active" : "None"}';
      });
    } catch (e) {
      setState(() {
        supabaseStatus = '❌ Failed: $e';
      });
    }
  }

  Future<void> _testAuth() async {
    setState(() {
      authStatus = 'Testing...';
    });

    try {
      final auth = FirebaseAuth.instance;
      
      // Check if user is already logged in
      if (auth.currentUser != null) {
        setState(() {
          authStatus = '✅ User logged in\nUID: ${auth.currentUser!.uid}';
        });
        return;
      }

      setState(() {
        authStatus = '⚠️ No user logged in\nTry login screen to test auth';
      });
    } catch (e) {
      setState(() {
        authStatus = '❌ Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9FBEF),
      appBar: AppBar(
        title: const Text('Backend Connection Test'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Backend Status',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Verify your Firebase and Supabase connections',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Firebase Core Status
                  _buildStatusCard(
                    'Firebase Core',
                    firebaseStatus,
                    Icons.cloud,
                  ),
                  const SizedBox(height: 16),

                  // Supabase Database Status (instead of Firestore)
                  _buildStatusCard(
                    'Supabase Database',
                    firestoreStatus,
                    Icons.storage,
                  ),
                  const SizedBox(height: 16),

                  // Supabase Connection Status
                  _buildStatusCard(
                    'Supabase API',
                    supabaseStatus,
                    Icons.cloud_circle,
                  ),
                  const SizedBox(height: 16),

                  // Auth Status
                  _buildStatusCard(
                    'Firebase Auth',
                    authStatus,
                    Icons.person,
                  ),
                  const SizedBox(height: 32),

                  // Test Auth Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testAuth,
                      icon: const Icon(Icons.security),
                      label: const Text('Test Authentication'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Refresh Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _runTests,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh All Tests'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF2ECC71),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Configuration Info
                  _buildConfigInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon) {
    final isSuccess = status.startsWith('✅');
    final isWarning = status.startsWith('⚠️');
    final isError = status.startsWith('❌');

    Color bgColor = Colors.grey.shade100;
    Color iconColor = Colors.grey;

    if (isSuccess) {
      bgColor = Colors.green.shade50;
      iconColor = Colors.green;
    } else if (isWarning) {
      bgColor = Colors.orange.shade50;
      iconColor = Colors.orange;
    } else if (isError) {
      bgColor = Colors.red.shade50;
      iconColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Firebase', EnvConfig.useFirebase ? 'Enabled' : 'Disabled'),
          _buildInfoRow('Supabase', EnvConfig.useSupabase ? 'Enabled' : 'Disabled'),
          _buildInfoRow('Backend', EnvConfig.activeBackend),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
