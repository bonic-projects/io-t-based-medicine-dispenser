import 'package:medicine/ui/smart_widgets/online_status/online_status.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'device_control_viewmodel.dart';

class DeviceControlView extends StackedView<DeviceControlViewModel> {
  const DeviceControlView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeviceControlViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.node != null) {
      return Card(
        // color: Colors.white10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Robot Control',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IsOnlineWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: viewModel.setServo1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          "${viewModel.deviceData.servo1 == viewModel.servoMinAngle ? "Open" : "Close"} Box1",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: viewModel.setServo2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Text(
                          "${viewModel.deviceData.servo2 == viewModel.servoMinAngle ? "Open" : "Close"} Box2",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Slider(
              value: viewModel.deviceData.servo3.toDouble(),
              min: 0,
              max: 180,
              divisions: 8,
              label: viewModel.deviceData.servo3.round().toString(),
              onChanged: viewModel.setServo3,
              onChangeEnd: (value) {
                viewModel.setDeviceData();
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  DeviceControlViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeviceControlViewModel();

  @override
  void onViewModelReady(DeviceControlViewModel viewModel) =>
      viewModel.setupDevice();
}
