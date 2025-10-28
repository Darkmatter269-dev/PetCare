import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // replaced: top-right rounded accent -> paw logo
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE8F7F2), Color(0xFFDFF7F0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.pets, // paw icon
                        size: 34,
                        color: Colors.teal[700],
                        semanticLabel: 'App paw logo',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                // Tab bar (Login / Sign Up)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: TabBar(
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.5, color: Colors.teal[400]!),
                      insets: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey[400],
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Login Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildInputCard(
                              icon: Icons.person_outline,
                              hint: 'Username',
                            ),
                            const SizedBox(height: 12),
                            _buildInputCard(
                              icon: Icons.lock_outline,
                              hint: 'Password',
                              obscure: true,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  // placeholder action
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.teal),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // no DB — go to home
                                  Navigator.of(context).pushReplacementNamed('/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF97E8C6), Color(0xFF7FE1B6)],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 56,
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sign Up Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildInputCard(icon: Icons.person_outline, hint: 'Full name'),
                            const SizedBox(height: 12),
                            _buildInputCard(icon: Icons.person_outline, hint: 'Username'),
                            const SizedBox(height: 12),
                            _buildInputCard(icon: Icons.lock_outline, hint: 'Password', obscure: true),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // fake signup -> go to home
                                  Navigator.of(context).pushReplacementNamed('/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF97E8C6), Color(0xFF7FE1B6)],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      )
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 56,
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildInputCard({
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          hintText: hint,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        ),
      ),
    );
  }
}