import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:scale_up/presentation/bloc/HomePage/home_page_cubit.dart";
import "package:scale_up/presentation/views/widgets/lesson_tile.dart";

class OngoingLessonsContainer extends StatelessWidget {
  const OngoingLessonsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    var lessons = context.watch<HomePageCubit>().state.ongoingLessons;

    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Ongoing Lessons", style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text("See All")),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 8,
            children: [for (var lesson in lessons) LessonTile(lesson: lesson)],
          ),
        ),
      ],
    );
  }
}
