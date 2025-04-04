import "package:flutter/material.dart";
import "package:scale_up/data/repositories/lessons/lesson.lessons_repository.dart";
import "package:scale_up/presentation/views/home/widgets/styles.dart";
import "package:scale_up/presentation/views/widgets/lesson_tile.dart";

class LessonGroup extends StatelessWidget {
  const LessonGroup({
    super.key,
    required this.categoryName,
    required this.lessons,
  });

  final String categoryName;
  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Styles.subtitle(categoryName),
        for (Lesson lesson in lessons) LessonTile(lesson: lesson),
      ],
    );
  }
}
