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
    final theme = Theme.of(context);

    return Scaffold(
      body: StepperPageView.form(
        physics: const NeverScrollableScrollPhysics(),
        pagePadding: const EdgeInsets.all(16),
        pageController: controller,
        onRequestNextPage: (currentPage, pageSteps, formKeys) {
          //
          return true;
        },
        pageSteps: [
          FormPageStep(
            title: const Text('Step 1'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hi, enter your name please!',
                  style: theme.textTheme.headline6,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'John Doe'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }

                    return null;
                  },
                ),
                Container(
                  height: 1000,
                  width: double.infinity,
                  color: Colors.pink,
                ),
              ],
            ),
          ),
          FormPageStep(
            title: const Text('Step 2'),
            content: Column(
              children: [
                const Spacer(),
                ElevatedButton(
                  child: const Text('howdy'),
                  onPressed: () {},
                )
              ],
            ),
          ),
          const FormPageStep(
            title: Text('Step 3'),
            content: Center(child: Text('Page 3')),
          ),
        ],
      ),
    );
  }
}
