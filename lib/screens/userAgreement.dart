import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UserAgreementScreen extends StatefulWidget {
  const UserAgreementScreen({Key? key}) : super(key: key);

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

class _UserAgreementScreenState extends State<UserAgreementScreen> {
  bool _isButtonEnabled = false;
  ScrollController _scrollController = ScrollController();

  void _onScroll() {
  final maxScroll = _scrollController.position.maxScrollExtent;
  final currentScroll = _scrollController.position.pixels;
  if (currentScroll >= maxScroll) {
    setState(() {
      _isButtonEnabled = true;
    });
  }
}

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Agreement'),
      ),
      body: SingleChildScrollView(
        // Listen to the scroll events
        scrollDirection: Axis.vertical,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        // Listen to the scroll events
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User agreement text
            const Text(
              '''
              User Agreement (“Agreement”) is entered into by and between [Your Company Name], (“Provider”), and the user (“User”) accessing the electric vehicle (EV) charging station (“Station”). By using the Station, User agrees to be bound by the terms and conditions of this Agreement.
              
              1. Access and Use
              1.1 Access: User is granted access to the Station for the sole purpose of charging electric vehicles in accordance with the terms of this Agreement.
              
              1.2 Authorized Use: User agrees to use the Station solely for its intended purpose and in compliance with all applicable laws, regulations, and guidelines.
              
              1.3 Prohibited Activities: User shall not use the Station for any unlawful, prohibited, or unauthorized purpose, including but not limited to, tampering with the Station, using the Station for commercial purposes without prior authorization, or any other activity that may disrupt or damage the Station.
              
              2. Charging Services
              2.1 Availability: Provider does not guarantee the availability of the Station at any given time. User acknowledges that the Station may be unavailable due to maintenance, repairs, or other operational reasons.
              
              2.2 Charging Process: User agrees to follow all instructions provided for charging at the Station, including but not limited to, connecting and disconnecting the charging cable properly.
              
              2.3 Fees: User may be subject to fees for using the Station, which shall be determined by Provider and communicated to User prior to charging. User agrees to pay all applicable fees for the use of the Station.
              
              3. Liability and Indemnification
              3.1 Limitation of Liability: Provider shall not be liable for any damages, losses, or injuries arising out of or in connection with the use of the Station, except to the extent caused by Provider’s negligence or willful misconduct.
              
              3.2 Indemnification: User agrees to indemnify, defend, and hold harmless Provider and its affiliates, officers, directors, employees, and agents from and against any and all claims, liabilities, damages, losses, costs, and expenses (including reasonable attorneys’ fees) arising out of or in connection with User’s use of the Station.
              
              4. Termination
              4.1 Termination by Provider: Provider reserves the right to terminate User’s access to the Station at any time for any reason, including but not limited to, violation of this Agreement or misuse of the Station.
              
              4.2 Termination by User: User may terminate this Agreement by ceasing to use the Station and notifying Provider of such termination.
              
              5. Miscellaneous
              5.1 Governing Law: This Agreement shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflicts of law principles.
              
              5.2 Entire Agreement: This Agreement constitutes the entire agreement between the parties with respect to the subject matter hereof and supersedes all prior and contemporaneous agreements and understandings, whether written or oral, relating to such subject matter.
              
              IN WITNESS WHEREOF, the parties have executed this Agreement as of the date User first accesses the Station.
              
              Provider: [Your Company Name]
              
              User: [User’s Name]
              
              [Signature lines for Provider and User]
              ''',
              style: TextStyle(fontSize: 16.0),
            ),
            // Accept button
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            Navigator.pushReplacementNamed(context, '/login');
                            print('User has accepted the agreement');
                          }
                        : null,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
