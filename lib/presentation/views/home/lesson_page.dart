import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:provider/provider.dart";
import "package:scale_up/data/repositories/lessons/chapter.lessons_repository.dart";
import "package:scale_up/data/repositories/lessons/lesson.lessons_repository.dart";
import "package:scale_up/data/repositories/lessons/lessons_repository.dart";
import "package:scale_up/presentation/bloc/LessonPage/lesson_page_bloc.dart";
import "package:scale_up/presentation/bloc/LessonPage/lesson_page_event.dart";
import "package:scale_up/presentation/views/home/widgets/styles.dart";
import "package:scale_up/presentation/views/widgets/unit_tile.dart";
import "package:scroll_animator/scroll_animator.dart";

class LessonPage extends StatelessWidget {
  const LessonPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    var lessonRepository = context.read<LessonsRepository>();

    return FutureBuilder(
      future: lessonRepository.getLesson(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snapshot.error.toString()),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        assert(snapshot.hasData);
        switch (snapshot.data) {
          case Lesson lesson:
            return MultiProvider(
              providers: [
                BlocProvider(create: (_) => LessonPageBloc(lesson)),
              ],
              child: LessonPageView(lesson: lesson),
            );
          case null:
            return BlankLessonPage(id: id);
        }
      },
    );
  }
}

class BlankLessonPage extends StatelessWidget {
  const BlankLessonPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Text("Lesson page"),
      ),
      body: Center(
        child: Text("Lesson not found '$id'"),
      ),
    );
  }
}

class LessonPageView extends StatelessWidget {
  const LessonPageView({
    required this.lesson,
    super.key,
  });

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        backgroundColor: lesson.color,
        foregroundColor: lesson.foregroundColor,
      ),
      body: InheritedProvider.value(
        value: lesson,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LessonDescription(),
            Expanded(child: LessonInformation()),
          ],
        ),
      ),
    );
  }
}

class LessonDescription extends StatelessWidget {
  const LessonDescription({super.key});

  @override
  Widget build(BuildContext context) {
    var lesson = context.read<Lesson>();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: lesson.color,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        spacing: 4.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Styles.title.copyWith(color: lesson.foregroundColor)(lesson.name),
          Styles.body.copyWith(color: lesson.foregroundColor)(lesson.description),
          const SizedBox(height: 4.0),
        ],
      ),
    );
  }
}

class LessonInformation extends StatelessWidget {
  const LessonInformation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // I don't want to create a StatefulWidget just to use this controller.
    //   Thankfully, providers automatically dispose of the values.
    return InheritedProvider(
      create: (_) => AnimatedScrollController(animationFactory: const ChromiumEaseInOut()),
      dispose: (_, v) => v.dispose(),
      builder: (context, child) => SingleChildScrollView(
        controller: context.read<AnimatedScrollController>(),
        child: child,
      ),
      child: LessonInformationView(),
    );
  }
}

class LessonInformationView extends StatelessWidget {
  const LessonInformationView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        spacing: 8.0,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LessonProgression(),
          LessonUnits(),
          LessonChapters(),
        ],
      ),
    );
  }
}

class LessonChapters extends StatelessWidget {
  const LessonChapters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Styles.subtitle("Lesson Content"),
        Column(
          spacing: 4.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var (index, chapter) in context.read<Lesson>().chapters.indexed)
              ChapterTile(index: index, chapter: chapter),
          ],
        )
      ],
    );
  }
}

class ChapterTile extends StatelessWidget {
  const ChapterTile({
    super.key,
    required this.index,
    required this.chapter,
  });

  final int index;
  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12.0,
      borderRadius: BorderRadius.circular(25.0),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: ChapterIndex(index: index),
        title: Styles.body(chapter.name, style: TextStyle(fontSize: 14)),
        subtitle: Styles.body(
          "${chapter.questionCount} questions",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        onTap: () => context.read<LessonPageBloc>().add(ChapterSelectedEvent(index)),
        tileColor: Colors.white,
      ),
    );
  }
}

class ChapterIndex extends StatelessWidget {
  const ChapterIndex({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Center(
            child: Styles.title(
              "${index + 1}",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonUnits extends StatelessWidget {
  const LessonUnits({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Styles.subtitle("Units Involved"),
        Column(
          spacing: 4.0,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var unit in context.read<Lesson>().units) UnitTile(unit: unit),
          ],
        )
      ],
    );
  }
}

class LessonProgression extends StatelessWidget {
  const LessonProgression({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var Lesson(:color, :chapterCount, :questionCount) = context.read();

    var completedChapters = chapterCount ~/ 2;
    var completedQuestions = questionCount ~/ 2;

    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Styles.subtitle("Progression"),
        LinearProgressIndicator(
          value: completedQuestions / questionCount,
          color: color,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Styles.body(
              "$completedChapters / $chapterCount chapters",
              style: TextStyle(color: color),
              textAlign: TextAlign.right,
            ),
            Styles.body(
              "$completedQuestions / $questionCount questions",
              style: TextStyle(color: color),
              textAlign: TextAlign.right,
            )
          ],
        ),
      ],
    );
  }
}
