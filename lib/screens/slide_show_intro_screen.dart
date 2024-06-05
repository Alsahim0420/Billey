import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_finances_app/screens/transaction_list_screen.dart';
import 'package:my_finances_app/theme/colors/app_colors.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: AppColors.primaryColorTransparent,
          height: size.height,
          width: size.width,
          child: PageView(
            controller: _pageController,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    "assets/svg/page_view_1.svg",
                    width: 200,
                    height: 200,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: const Text(
                      "My Finances es una app dpnde podras organizar tus finanzas y llevar el control de ellas!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      child: const Text("SIGUIENTE"))
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SvgPicture.asset(
                    "assets/svg/page_view_2.svg",
                    width: 200,
                    height: 200,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: const Text(
                      "Estas a un paso de comenzar esta experiencia, animate a empezar a llevar un orden de tus finanzas",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const TransactionListScreen(),
                          ),
                        );
                      },
                      child: const Text("IR A ORGANIZAR MIS FINANZAS"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
