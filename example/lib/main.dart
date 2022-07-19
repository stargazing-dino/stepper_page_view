import 'package:flutter/material.dart';
import 'package:stepper_page_view/stepper_page_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stepper page view example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StepperPageView(
        pageController: controller,
        pageSteps: const [
          PageStep(
            title: Text('Step 1'),
            content: Center(child: Text('Page 1')),
          ),
          PageStep(
            title: Text('Step 2'),
            content: Center(child: Text('Page 2')),
          ),
          PageStep(
            title: Text('Step 3'),
            content: Center(child: Text('Page 3')),
          ),
        ],
      ),
    );
  }
}
