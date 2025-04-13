import "package:flutter/material.dart" hide SearchBar;
import "package:flutter_bloc/flutter_bloc.dart";
import "package:scale_up/presentation/bloc/HomePage/home_page_cubit.dart";
import "package:scale_up/presentation/views/home/home_page/explore_lesson_container.dart";
import "package:scale_up/presentation/views/home/home_page/featured_lessons_container.dart";
import "package:scale_up/presentation/views/home/home_page/ongoing_lessons_container.dart";
import "package:scale_up/presentation/views/home/home_page/search_bar.dart";
import "package:scale_up/presentation/views/home/home_page/user_bar.dart";

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomePageCubit(firestoreHelper: context.read()),
      child: HomePageView(),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          children: [
            UserBar(),
            Expanded(
              child: Column(
                spacing: 16.0,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchBar(),
                  FeaturedLessonsContainer(),
                  OngoingLessonsContainer(),
                  ExploreLessonsContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
