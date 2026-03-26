// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mini_reddit_v2/features/auth/presentation/providers/auth_provider.dart';
// import 'complete_profile_screen.dart';

// class VerifyEmailScreen extends ConsumerStatefulWidget {
//   final String email;
//   const VerifyEmailScreen({super.key, required this.email});

//   @override
//   ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
//   final _codeController = TextEditingController();

//   @override
//   void dispose() {
//     _codeController.dispose();
//     super.dispose();
//   }

//   void _verify() {
//     ref
//         .read(authProvider.notifier)
//         .verifyEmail(widget.email, _codeController.text.trim());
//   }

//   void _resendOtp() {
//     ref.read(authProvider.notifier).resendOtp(widget.email);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authProvider);

//     ref.listen(authProvider, (previous, next) {
//       if (next.isSuccess) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CompleteProfileScreen(),
//           ),
//         );
//       } else if (next.errorMessage != null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(next.errorMessage.toString()),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     });

//     return Scaffold(
//       appBar: AppBar(title: const Text('Verify Email')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.mark_email_read_outlined,
//                 size: 80,
//                 color: Colors.blue,
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Enter Verification Code',
//                 style: Theme.of(context).textTheme.headlineMedium,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'We sent a 6-digit code to ${widget.email}',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               TextField(
//                 controller: _codeController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   hintText: '6-digit code',
//                   prefixIcon: Icon(Icons.lock_clock_outlined),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: authState.isLoading ? null : _verify,
//                 child: authState.isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text('Verify'),
//               ),
//               const SizedBox(height: 32),

//               ElevatedButton(
//                 onPressed: authState.isLoading ? null : _resendOtp,
//                 child: authState.isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text('resend otp'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
