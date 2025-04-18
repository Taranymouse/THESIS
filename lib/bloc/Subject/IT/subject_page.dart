import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/modles/subject_model.dart';
import 'subject_bloc.dart';
import 'grade_selection_cubit.dart';


class SubjectPage extends StatefulWidget {
  @override
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final int limit = 10;
  int currentOffset = 0;

  @override
  void initState() {
    super.initState();
    context.read<SubjectBloc>().add(LoadSubjectsEvent(offset: currentOffset, limit: limit));
  }

  void loadNextPage() {
    setState(() {
      currentOffset += limit;
    });
    context.read<SubjectBloc>().add(LoadSubjectsEvent(offset: currentOffset, limit: limit));
  }

  void loadPreviousPage() {
    if (currentOffset >= limit) {
      setState(() {
        currentOffset -= limit;
      });
      context.read<SubjectBloc>().add(LoadSubjectsEvent(offset: currentOffset, limit: limit));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<SubjectBloc, SubjectState>(
          builder: (context, state) {
            if (state is SubjectLoading) return CircularProgressIndicator();
            if (state is SubjectLoaded) {
              return Expanded(
                child: ListView.builder(
                  itemCount: state.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = state.subjects[index];
                    return SubjectRow(subject: subject);
                  },
                ),
              );
            }
            return Text('Load failed');
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(onPressed: loadPreviousPage, child: Text('Previous')),
            ElevatedButton(onPressed: loadNextPage, child: Text('Next')),
          ],
        ),
        BlocBuilder<GradeSelectionCubit, Map<int, String>>(
          builder: (context, state) {
            final passedCount = context.read<GradeSelectionCubit>().countPassedSubjects();
            return Text('ผ่านแล้ว: $passedCount วิชา');
          },
        )
      ],
    );
  }
}

class SubjectRow extends StatelessWidget {
  final Subject subject;

  const SubjectRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(subject.name_subjects),
      trailing: DropdownButton<String>(
        value: context.watch<GradeSelectionCubit>().state[subject.id_subject],
        items: ['A', 'B', 'C', 'D', 'F']
            .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
            .toList(),
        hint: Text('เลือกเกรด'),
        onChanged: (value) {
          if (value != null) {
            context.read<GradeSelectionCubit>().updateGrade(subject.id_subject, value);
          }
        },
      ),
    );
  }
}
