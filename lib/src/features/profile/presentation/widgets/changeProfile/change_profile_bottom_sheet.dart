import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/blocs/user/user_cubit.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';
import 'package:healthlife/src/features/complete_profile/data/repositories/profile_repository.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/gender.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/height_unit.dart';
import 'package:healthlife/src/features/complete_profile/domains/enums/weight_unit.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/date/box_date.dart';
import 'package:healthlife/src/features/complete_profile/presentation/widgets/weight/toggle_pill.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/changeProfile/change_profile_cubit.dart';
import 'package:healthlife/src/features/profile/presentation/cubit/changeProfile/change_profile_state.dart';
import 'package:healthlife/src/shared/enums/bloc_status.dart';

Future<void> showChangeProfileSheet(BuildContext context) async {
  final user = context.read<UserCubit>().state.user;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => BlocProvider(
      create: (_) => ChangeProfileCubit(ProfileRepository(), user: user),
      child: const _ChangeProfileSheet(),
    ),
  );
}

class _ChangeProfileSheet extends StatelessWidget {
  const _ChangeProfileSheet();

  String? _errorText(ChangeProfileState state) {
    if (state.nameError) return 'Vui lòng nhập tên của bạn';
    if (state.dayError || state.monthError || state.yearError) {
      return 'Vui lòng nhập đúng ngày tháng năm sinh';
    }
    if (state.heightError) return 'Vui lòng nhập chiều cao hợp lệ';
    if (state.weightError) return 'Vui lòng nhập cân nặng hợp lệ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChangeProfileCubit, ChangeProfileState>(
      listener: (context, state) {
        if (state.status == BlocStatus.success) {
          final messenger = ScaffoldMessenger.of(context);
          context.read<UserCubit>().loadUser();
          Navigator.of(context).pop();
          messenger.showSnackBar(
            const SnackBar(content: Text('Đã cập nhật thông tin')),
          );
        } else if (state.status == BlocStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lưu thất bại: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ChangeProfileCubit>();
        final isSaving = state.status == BlocStatus.loading;
        final errorText = _errorText(state);

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              context.paddingBottomForButton + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold('Thông tin cơ bản', fontSize: 18),
                20.gap,
                AppText.medium('Họ tên', fontSize: 13),
                6.gap,
                AppTF.common(
                  controller: cubit.nameController,
                  keyboardType: TextInputType.name,
                  onChanged: cubit.onChangeName,
                ),
                20.gap,
                AppText.medium('Giới tính', fontSize: 13),
                10.gap,
                TogglePill(
                  labels: const ['Nam', 'Nữ'],
                  selectedIndex: state.gender == Gender.male ? 1 : 0,
                  onChanged: (i) =>
                      cubit.setGender(i == 0 ? Gender.female : Gender.male),
                ),
                20.gap,
                AppText.medium('Ngày sinh', fontSize: 13),
                10.gap,
                Row(
                  children: [
                    DateFieldItem(
                      label: 'Ngày',
                      controller: cubit.dayController,
                      keyboardType: TextInputType.number,
                      maxNum: 2,
                      onChanged: cubit.onChangeDay,
                      hasError: state.dayError,
                    ),
                    14.gap,
                    DateFieldItem(
                      label: 'Tháng',
                      controller: cubit.monthController,
                      keyboardType: TextInputType.number,
                      maxNum: 2,
                      onChanged: cubit.onChangeMonth,
                      hasError: state.monthError,
                    ),
                    14.gap,
                    DateFieldItem(
                      label: 'Năm',
                      controller: cubit.yearController,
                      keyboardType: TextInputType.number,
                      maxNum: 4,
                      hintText: '2005',
                      onChanged: cubit.onChangeYear,
                      hasError: state.yearError,
                    ),
                  ],
                ),
                20.gap,
                AppText.medium('Chiều cao', fontSize: 13),
                10.gap,
                Row(
                  children: [
                    Expanded(
                      child: AppTF.common(
                        controller: cubit.heightController,
                        keyboardType: TextInputType.number,
                        onChanged: cubit.onHeightTextChanged,
                        rightWidget: AppText.medium(
                          state.heightUnit == HeightUnit.cm ? 'cm' : 'ft',
                          color: UIColors.textBody,
                        ),
                      ),
                    ),
                    12.gap,
                    TogglePill(
                      labels: const ['cm', 'ft'],
                      selectedIndex: state.heightUnit == HeightUnit.cm ? 0 : 1,
                      onChanged: (i) => cubit.setHeightUnit(
                        i == 0 ? HeightUnit.cm : HeightUnit.ft,
                      ),
                    ),
                  ],
                ),
                20.gap,
                AppText.medium('Cân nặng', fontSize: 13),
                10.gap,
                Row(
                  children: [
                    Expanded(
                      child: AppTF.common(
                        controller: cubit.weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: cubit.onWeightTextChanged,
                        rightWidget: AppText.medium(
                          state.weightUnit == WeightUnit.kg ? 'kg' : 'lbs',
                          color: UIColors.textBody,
                        ),
                      ),
                    ),
                    12.gap,
                    TogglePill(
                      labels: const ['kg', 'lbs'],
                      selectedIndex: state.weightUnit == WeightUnit.kg ? 0 : 1,
                      onChanged: (i) => cubit.setWeightUnit(
                        i == 0 ? WeightUnit.kg : WeightUnit.lbs,
                      ),
                    ),
                  ],
                ),
                if (errorText != null) ...[
                  16.gap,
                  AppText.medium(
                    errorText,
                    fontSize: 13,
                    color: UIColors.coral,
                    maxLines: 3,
                  ),
                ],
                24.gap,
                AppButton.fill(
                  height: 46,
                  width: double.infinity,
                  color: UIColors.pink,
                  enable: !isSaving,
                  titleWidget: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AppText.semiBold(
                          'Thay đổi thông tin',
                          fontSize: 15,
                          color: UIColors.white,
                        ),
                  onTap: () => cubit.saveChange(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}