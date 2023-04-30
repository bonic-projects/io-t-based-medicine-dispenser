import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'online_status_viewmodel.dart';

class IsOnlineWidget extends StatelessWidget {
  const IsOnlineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OnlineStatusViewModel>.reactive(
      onViewModelReady: (model) => model.setTimer(),
      builder: (context, model, child) {
        if (model.isOnline) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: const [
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 16,
                )
              ],
            ),
          ));
        } else {
          return const Center(
              child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text(
              'Offline',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ));
        }
      },
      viewModelBuilder: () => OnlineStatusViewModel(),
    );
  }
}
