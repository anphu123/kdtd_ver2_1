import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';

enum QuestionGroup { general, iosOnly, foldableOnly }

class QuestionChoice {
  final String label;
  final int value;

  const QuestionChoice({required this.label, required this.value});
}

class QuestionCheckItem {
  final String id;
  final String title;
  final QuestionGroup group;
  final List<QuestionChoice> choices;

  const QuestionCheckItem({
    required this.id,
    required this.title,
    required this.group,
    required this.choices,
  });
}

List<QuestionCheckItem> getQuestionCheckItems() {
  return [
    // Nhóm A
    QuestionCheckItem(
      id: 'q1',
      title: LocaleKeys.question_check_q1_title.trans(),
      group: QuestionGroup.general,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q1_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q1_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q2',
      title: LocaleKeys.question_check_q2_title.trans(),
      group: QuestionGroup.general,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q2_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q2_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q3',
      title: LocaleKeys.question_check_q3_title.trans(),
      group: QuestionGroup.general,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q3_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q3_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q4',
      title: LocaleKeys.question_check_q4_title.trans(),
      group: QuestionGroup.general,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q4_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q4_c2.trans(), value: 2),
        QuestionChoice(label: LocaleKeys.question_check_q4_c3.trans(), value: 3),
        QuestionChoice(label: LocaleKeys.question_check_q4_c4.trans(), value: 4),
        QuestionChoice(label: LocaleKeys.question_check_q4_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q5',
      title: LocaleKeys.question_check_q5_title.trans(),
      group: QuestionGroup.general,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q5_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q5_c2.trans(), value: 2),
        QuestionChoice(label: LocaleKeys.question_check_q5_c3.trans(), value: 3),
        QuestionChoice(label: LocaleKeys.question_check_q5_c4.trans(), value: 4),
        QuestionChoice(label: LocaleKeys.question_check_q5_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q6',
      title: LocaleKeys.question_check_q6_title.trans(),
      group: QuestionGroup.general,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q6_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q6_c2.trans(), value: 2),
        QuestionChoice(label: LocaleKeys.question_check_q6_c3.trans(), value: 3),
        QuestionChoice(label: LocaleKeys.question_check_q6_c4.trans(), value: 4),
        QuestionChoice(label: LocaleKeys.question_check_q6_c5.trans(), value: 5),
      ],
    ),
    // Nhóm B
    QuestionCheckItem(
      id: 'q7',
      title: LocaleKeys.question_check_q7_title.trans(),
      group: QuestionGroup.iosOnly,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q7_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q7_c2.trans(), value: 2),
      ],
    ),
    QuestionCheckItem(
      id: 'q8',
      title: LocaleKeys.question_check_q8_title.trans(),
      group: QuestionGroup.iosOnly,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q8_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q8_c3.trans(), value: 3),
        QuestionChoice(label: LocaleKeys.question_check_q8_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q9',
      title: LocaleKeys.question_check_q9_title.trans(),
      group: QuestionGroup.iosOnly,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q9_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q9_c3.trans(), value: 3),
        QuestionChoice(label: LocaleKeys.question_check_q9_c5.trans(), value: 5),
      ],
    ),
    // Nhóm C
    QuestionCheckItem(
      id: 'q10',
      title: LocaleKeys.question_check_q10_title.trans(),
      group: QuestionGroup.foldableOnly,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q10_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q10_c4.trans(), value: 4),
        QuestionChoice(label: LocaleKeys.question_check_q10_c5.trans(), value: 5),
      ],
    ),
    QuestionCheckItem(
      id: 'q11',
      title: LocaleKeys.question_check_q11_title.trans(),
      group: QuestionGroup.foldableOnly,
      choices: [
        QuestionChoice(label: LocaleKeys.question_check_q11_c1.trans(), value: 1),
        QuestionChoice(label: LocaleKeys.question_check_q11_c5.trans(), value: 5),
      ],
    ),
  ];
}
