import 'package:bytegarden/classes/device.dart';
import 'package:bytegarden/resources/colors.dart';
import 'package:bytegarden/services/garden_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..forward(from: 0);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  List<Device> devices = [];
  GardenService service = GardenFactory.getGardenService()!;
  bool subscribed = false;
  bool enabled = false;

  @override
  void initState() {
    super.initState();

    if (!subscribed) {
      service.load().then((value) async {
        debugPrint(
            'Service status check :: 1 :: ' + service.isEnabled.toString());
        if (service.isEnabled) {
          setState(() {
            devices = service.getCachedDevices();
            enabled = service.isEnabled;
          });
        } else {
          setState(() {
            enabled = service.isEnabled;
          });
        }
      });

      service.onStateChange +
          ((args) async {
            debugPrint(
                'Event status changed :: 2 :: ' + args!.state.toString());
            if (args.state) {
              setState(() {
                devices = devices = service.getCachedDevices();
                enabled = args.state;
              });
            } else {
              setState(() {
                enabled = args.state;
              });
            }
          });

      subscribed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23.0),
        ),
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: const Text('Bluetooth'),
                margin: const EdgeInsets.all(10),
              ),
              ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      key: GlobalKey(debugLabel: 'enableBlSetting'),
                      visualDensity: VisualDensity.compact,
                      iconColor: textPrimaryColor,
                      leading: const Icon(Icons.bluetooth),
                      title: const Text('Enable'),
                      trailing: Switch(
                        value: enabled,
                        activeColor: buttonColor,
                        onChanged: (value) => {
                          Future(() async {
                            var status =
                                await Permission.bluetoothConnect.request();

                            if (status.isGranted) {
                              if (value) {
                                await service.enable();
                              } else {
                                await service.disable();
                              }
                            } else {
                              var message =
                                  'Cant enable or disable because connect permission is not granted';
                              debugPrint(message);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                  message,
                                  style:
                                      const TextStyle(color: textPrimaryColor),
                                ),
                                backgroundColor: secondaryColor,
                              ));
                            }
                          })
                        },
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      key: GlobalKey(debugLabel: 'devicesBlSetting'),
                      visualDensity: VisualDensity.compact,
                      iconColor: textPrimaryColor,
                      leading: const Icon(Icons.list_rounded),
                      title: const Text('Devices'),
                      trailing: enabled
                          ? const Icon(Icons.keyboard_arrow_down_rounded)
                          : const Icon(Icons.keyboard_arrow_right_rounded),
                    ),
                  ),
                ],
              ),
              enabled
                  ? Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: FadeTransition(
                        opacity: _animation,
                        child: ListView.builder(
                            key: UniqueKey(),
                            shrinkWrap: true,
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  onTap: () => devices[index].isConnected
                                      ? _tryDisconnection(devices[index])
                                      : _tryConnection(devices[index]),
                                  iconColor: textPrimaryColor,
                                  key: ValueKey(devices[index].address),
                                  leading: const Icon(Icons.developer_board),
                                  title: Text(devices[index].name == null
                                      ? devices[index].address
                                      : devices[index].name.toString()),
                                  subtitle: Text(devices[index].name == null
                                      ? ''
                                      : devices[index].address),
                                  visualDensity: VisualDensity.compact,
                                  trailing: DecoratedBox(
                                    child: const SizedBox(
                                      width: 17,
                                      height: 17,
                                    ),
                                    decoration: ShapeDecoration(
                                        shape: const CircleBorder(),
                                        color: devices[index].isConnected
                                            ? Colors.green
                                            : Colors.yellow),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        )
      ]),
    );
  }

  void _onLoading(String name, {bool connecting = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: primaryColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          child: Container(
            width: 150,
            height: 360,
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Column(children: [
                LoadingIndicator(
                  colors: connecting
                      ? [buttonColor, Colors.yellow, Colors.green]
                      : [buttonColor, Colors.green, Colors.yellow],
                  indicatorType: Indicator.pacman,
                  backgroundColor: primaryColor,
                  pathBackgroundColor: primaryColor,
                ),
                Text(
                  connecting
                      ? 'Connecting to "$name"'
                      : 'Disconnecting from "$name"',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                )
              ]),
            ),
          ),
        );
      },
    );
  }

  void _tryConnection(Device device) async {
    var status = await Permission.bluetoothScan.request();
    if (status.isGranted) {
      _onLoading(device.getName());
      if (await service.connect(device)) {
        var d = await service.getDevices();
        await Hive.box('settings')
            .put('favorite_device', [device.getName(), device.address]);
        setState(() {
          devices = d;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Connected',
            style: TextStyle(color: textPrimaryColor),
          ),
          backgroundColor: secondaryColor,
        ));
      } else {
        var message = 'Error connecting to device';
        debugPrint(message);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: textPrimaryColor),
          ),
          backgroundColor: secondaryColor,
        ));
      }
      Navigator.pop(context); //pop dialog
    } else {
      var message = 'Cant connect permission is not granted';
      debugPrint(message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: textPrimaryColor),
        ),
        backgroundColor: secondaryColor,
      ));
    }
  }

  void _tryDisconnection(Device device) async {
    var status = await Permission.bluetoothScan.request();
    if (status.isGranted) {
      _onLoading(
        device.getName(),
        connecting: false,
      );
      if (await service.disconnect()) {
        var d = await service.getDevices();
        setState(() {
          devices = d;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Disconnected from ${device.getName()}',
            style: const TextStyle(color: textPrimaryColor),
          ),
          backgroundColor: secondaryColor,
        ));
      } else {
        var message = 'Error disconnecting to device';
        debugPrint(message);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: textPrimaryColor),
          ),
          backgroundColor: secondaryColor,
        ));
      }
      Navigator.pop(context); //pop dialog
    } else {
      var message = 'Cant connect permission is not granted';
      debugPrint(message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: textPrimaryColor),
        ),
        backgroundColor: secondaryColor,
      ));
    }
  }
}
