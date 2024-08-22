import 'package:medicine/ui/smart_widgets/online_status/online_status.dart';
import 'package:flutter/material.dart';
import 'package:medicine/ui/widgets/customButton.dart';
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
    if (viewModel.node != null &&
        viewModel.node2 != null &&
        viewModel.deviceData != null &&
        viewModel.user != null) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // if (!viewModel.isDispensing)
            Card(
              child: Column(
                children: [
                  CustomButton(
                      onTap: () {
                        viewModel.dispense(1);
                      },
                      text:
                          "Dispense medicine 1 | Available: ${viewModel.deviceData!.m1}",
                      isLoading: viewModel.isDispensing),
                  CustomButton(
                      onTap: () {
                        viewModel.dispense(2);
                      },
                      text:
                          "Dispense medicine 2 | Available: ${viewModel.deviceData!.m2}",
                      isLoading: viewModel.isDispensing),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: CustomButton(
            //       onTap: viewModel.setStatusView,
            //       text: viewModel.isStatus ? "Hide status" : "Show status",
            //       isLoading: false),
            // ),
            // if (viewModel.isStatus || viewModel.isDispensing)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Status: ${viewModel.status}",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 24),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Pin entered: ${viewModel.node2!.pin}"),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("RFID scanned: ${viewModel.node!.rfid}"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.8),
            Card(
              // color: Colors.white10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 16.0),
                  //   child: Text(
                  //     "Manual Controller",
                  //     textAlign: TextAlign.left,
                  //     style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                            onTap: viewModel.setServo1,
                            text:
                                "${viewModel.deviceData!.servo1 == viewModel.servoMinAngle ? "Open" : "Close"} Box1",
                            isLoading: false),
                        CustomButton(
                            onTap: viewModel.setServo2,
                            text:
                                "${viewModel.deviceData!.servo2 == viewModel.servoMinAngle ? "Open" : "Close"} Box2",
                            isLoading: false),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                            onTap: viewModel.setGreenLed,
                            text:
                                "${!viewModel.deviceData!.greenLed ? "On" : "Off"} Green LED",
                            isLoading: false),
                        CustomButton(
                            onTap: viewModel.setRedLed,
                            text:
                                "${!viewModel.deviceData!.redLed ? "On" : "Off"} Red LED",
                            isLoading: false),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                            onTap: viewModel.setBuzzer,
                            text:
                                "${!viewModel.deviceData!.buzzer ? "On" : "Off"} Buzzer",
                            isLoading: false),
                        CustomButton(
                            onTap: () {},
                            text: viewModel.node!.rfid,
                            isLoading: false),
                      ],
                    ),
                  ),
                  // Slider(
                  //   value: viewModel.deviceData.redLed.toDouble(),
                  //   min: 0,
                  //   max: 180,
                  //   divisions: 8,
                  //   label: viewModel.deviceData.redLed.round().toString(),
                  //   onChanged: viewModel.setServo3,
                  //   onChangeEnd: (value) {
                  //     viewModel.setDeviceData();
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
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
