import 'package:medicine/ui/smart_widgets/device_control/device_control.dart';
import 'package:medicine/ui/smart_widgets/online_status/online_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Robo'),
          actions: [
            if (viewModel.user != null)
              IconButton(
                onPressed: viewModel.logout,
                icon: const Icon(Icons.logout),
              ),
            IsOnlineWidget()
          ],
        ),
        body: Container(
          child: DeviceControlView(),
        ));
  }

  @override
  HomeViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}
