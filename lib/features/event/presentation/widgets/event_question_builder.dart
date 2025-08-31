import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbours/core/components/custom_button.dart';
import 'package:neighbours/core/components/custom_gap.dart';
import 'package:neighbours/core/components/reusable_text_field.dart';
import 'package:neighbours/core/extensions/context_ext.dart';
import 'package:neighbours/features/event/presentation/cubits/event_form/event_form_cubit.dart';

class EventQuestionBuilder extends StatefulWidget {
  const EventQuestionBuilder({super.key});

  @override
  State<EventQuestionBuilder> createState() => _EventQuestionBuilderState();
}

class _EventQuestionBuilderState extends State<EventQuestionBuilder> {
  final List<TextEditingController> _controllers = [];
  final _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _questionController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    final state = context.read<EventFormCubit>().state;
    _controllers.clear();

    for (int i = 0; i < state.votingOptions.length; i++) {
      final controller = TextEditingController(text: state.votingOptions[i]);
      _controllers.add(controller);
    }
  }

  void _updateControllers() {
    final state = context.read<EventFormCubit>().state;

    // Удаляем лишние контроллеры
    while (_controllers.length > state.votingOptions.length) {
      _controllers.removeLast().dispose();
    }

    // Добавляем недостающие контроллеры
    while (_controllers.length < state.votingOptions.length) {
      final index = _controllers.length;
      final controller =
          TextEditingController(text: state.votingOptions[index]);
      _controllers.add(controller);
    }

    // Обновляем текст в существующих контроллерах
    for (int i = 0; i < state.votingOptions.length; i++) {
      if (_controllers[i].text != state.votingOptions[i]) {
        _controllers[i].text = state.votingOptions[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventFormCubit, EventFormState>(
      builder: (context, state) {
        _updateControllers();

        return Column(
          children: [
            const VerticalGap(8),
            ReusableTextField(
              controller: _questionController,
              hintText: 'Введите вопрос',
              errorText: state.votingQuestionError,
              onChange: (value) =>
                  context.read<EventFormCubit>().setVotingQuestion(value),
            ),
            const VerticalGap(8),
            ListView.separated(
              separatorBuilder: (context, index) => const VerticalGap(8),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.votingOptions.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: ReusableTextField(
                        controller: _controllers[index],
                        hintText: 'Введите вариант ответа',
                        onChange: (value) {
                          context
                              .read<EventFormCubit>()
                              .updateQuestion(index, value);
                        },
                      ),
                    ),
                    const HorizontalGap(8),
                    CustomButton(
                      onPressed: () =>
                          context.read<EventFormCubit>().removeQuestion(index),
                      style: BoxDecoration(
                          color: context.color.basicRed,
                          shape: BoxShape.circle),
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                      height: 24,
                      width: 24,
                    )
                  ],
                );
              },
            ),
            const VerticalGap(8),
            if (_controllers.length < 10) _addQuestionButton()
          ],
        );
      },
    );
  }

  Widget _addQuestionButton() {
    return GestureDetector(
      onTap: () => context.read<EventFormCubit>().addQuestion(),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: context.color.primary, shape: BoxShape.circle),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
          const HorizontalGap(8),
          Text(
            'Добавить ответ',
            style:
                context.text.bodyMedium.copyWith(color: context.color.primary),
          )
        ],
      ),
    );
  }
}
