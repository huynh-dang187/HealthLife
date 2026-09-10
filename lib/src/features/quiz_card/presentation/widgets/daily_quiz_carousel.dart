import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

import '../../data/models/quiz_question.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../domains/enums/quiz_option.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_option.dart';

class DailyQuizCarousel extends StatelessWidget {
  const DailyQuizCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(QuizRepository())..loadToday(),
      child: const _CarouselView(),
    );
  }
}

class _CarouselView extends StatelessWidget {
  const _CarouselView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        return switch (state.status) {
          BlocStatus.loading || BlocStatus.initial => const SizedBox(
            height: 96,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          BlocStatus.failure => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppText.regular(
              'Hôm nay chưa có câu hỏi, bạn thử lại sau nhé',
              fontSize: 13,
              color: UIColors.textBody,
            ),
          ),
          BlocStatus.success when state.questions.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppText.regular(
              'Hôm nay chưa có câu hỏi, bạn thử lại sau nhé',
              fontSize: 13,
              color: UIColors.textBody,
            ),
          ),
          BlocStatus.success => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < state.questions.length; i++) ...[
                    if (i > 0) 10.gap,
                    _QuizCard(
                      question: state.questions[i],
                      state: state,
                      index: i,
                    ),
                  ],
                ],
              ),
            ),
          ),
        };
      },
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.question,
    required this.state,
    required this.index,
  });

  final QuizQuestion question;
  final QuizState state;
  final int index;

  QuizOptionState _optionState(int optionIndex) {
    if (!state.isAnswered(index)) {
      return state.selectedFor(index) == optionIndex
          ? QuizOptionState.selected
          : QuizOptionState.normal;
    }
    if (optionIndex == question.correctIndex) return QuizOptionState.correct;
    if (optionIndex == state.selectedFor(index)) return QuizOptionState.wrong;
    return QuizOptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.medium(
            question.category,
            fontSize: 10,
            color: UIColors.pink,
          ),
          6.gap,
          AppText.medium(
            question.question,
            fontSize: 13,
            maxLines: 2,
            color: UIColors.text,
          ),
          10.gap,
          for (var i = 0; i < question.options.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: state.isAnswered(index)
                  ? null
                  : () => cubit.selectAnswer(index, i),
              child: QuizOption(
                label: question.options[i],
                state: _optionState(i),
              ),
            ),
            if (i != question.options.length - 1) 4.gap,
          ],
          if (state.isAnswered(index)) ...[
            10.gap,
            _buildResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    final correct = state.selectedFor(index) == question.correctIndex;
    final color = correct ? UIColors.green : UIColors.coral;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: color,
              ),
              4.gap,
              Expanded(
                child: AppText.semiBold(
                  correct
                      ? 'Chính xác!'
                      : 'Đáp án đúng: ${question.correctOption}',
                  fontSize: 11,
                  color: color,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          if (question.explanation.isNotEmpty) ...[
            4.gap,
            AppText.regular(
              question.explanation,
              fontSize: 10,
              color: UIColors.textBody,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }
}
