import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/features/introduction/presentation/cubit/introduction_cubit.dart';
import 'package:healthlife/src/features/introduction/presentation/widget/introduction_bottom_content.dart';
import 'package:healthlife/src/features/introduction/presentation/widget/introduction_page_item.dart';
import 'package:healthlife/src/features/introduction/presentation/widget/language_dropdown.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IntroductionCubit(),
      child: Scaffold(
        body: BlocBuilder<IntroductionCubit, IntroductionState>(
          builder: (context, state) {
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  onPageChanged: context
                      .read<IntroductionCubit>()
                      .onPageChanged,
                  itemBuilder: (context, index) =>
                      IntroductionPageItem(data: state.pages[index]),
                ),
                Positioned(
                  top: context.topPadding,
                  right: 16,
                  child: const LanguageDropdown(),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IntroductionBottomContent(
                    description: state.pages[state.currentPage].description,
                    currentPage: state.currentPage,
                    pageCount: state.pages.length,
                    isLastPage: state.isLastPage,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
