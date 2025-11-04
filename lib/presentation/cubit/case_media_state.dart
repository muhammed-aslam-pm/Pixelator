part of 'case_media_cubit.dart';

class CaseMediaState extends Equatable {
  final bool loading;
  final List<MediaFileEntity> items;
  final Map<String, double> progress;
  final String? error;

  const CaseMediaState({
    this.loading = false,
    this.items = const [],
    this.progress = const {},
    this.error,
  });

  CaseMediaState copyWith({
    bool? loading,
    List<MediaFileEntity>? items,
    Map<String, double>? progress,
    String? error,
  }) {
    return CaseMediaState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      progress: progress ?? this.progress,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, items, progress, error];
}

