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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Atm: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (model.isOnline)
              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 16,
              )
            else
              const Icon(
                Icons.circle,
                color: Colors.red,
                size: 16,
              ),
            const SizedBox(width: 10),
            const Text(
              'Pin: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (model.isOnlineBand)
              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 16,
              )
            else
              const Icon(
                Icons.circle,
                color: Colors.red,
                size: 16,
              )
          ],
        );
      },
      viewModelBuilder: () => OnlineStatusViewModel(),
    );
  }
}
