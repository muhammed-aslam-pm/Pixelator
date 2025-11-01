import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/logout_cubit.dart';
import '../cubit/cases_cubit.dart';
import '../widgets/app_drawer.dart';
import '../widgets/case_summary_cards.dart';
import '../widgets/case_filters_bar.dart';
import '../widgets/cases_table.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/case_entity.dart';
import '../../domain/entities/cases_response_entity.dart';
import '../../core/di/injection_container.dart' as di;

class HomePage extends StatefulWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  int? _priorityFilter;
  int _currentPage = 1;
  int _pageSize = 20;
  Timer? _debounceTimer;
  CasesResponseEntity? _lastResponse;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _handleSearch(String query, CasesCubit cubit) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce search - wait 500ms before making API call
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadCases(cubit);
    });
  }

  void _handlePriorityChange(String? priority, CasesCubit cubit) {
    setState(() {
      _priorityFilter = priority != null ? int.tryParse(priority) : null;
      _currentPage = 1;
    });
    _loadCases(cubit);
  }

  void _handleFiltersTap() {
    // TODO: Open filters dialog
  }

  void _handlePageChanged(int page, CasesCubit cubit) {
    setState(() {
      _currentPage = page;
    });
    _loadCases(cubit);
  }

  void _handlePageSizeChanged(int size, CasesCubit cubit) {
    setState(() {
      _pageSize = size;
      _currentPage = 1;
    });
    _loadCases(cubit);
  }

  void _loadCases(CasesCubit cubit) {
    // Search can match case_name, case_no, hospital_name, or patient_id
    cubit.getCases(
      caseName: _searchQuery.isNotEmpty ? _searchQuery : null,
      priority: _priorityFilter,
      page: _currentPage,
      size: _pageSize,
      sort: '-created_at',
    );
  }

  int _calculateActiveCases(List<CaseEntity> cases) {
    return cases.where((c) => c.status == 'active').length;
  }

  int _calculatePendingCases(List<CaseEntity> cases) {
    return cases.where((c) => c.status == 'pending').length;
  }

  int _calculateCompletedCases(List<CaseEntity> cases) {
    return cases.where((c) => c.isCompleted == true).length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(di.sl()),
      child: BlocProvider(
        create: (_) => CasesCubit(di.sl())
          ..getCases(page: _currentPage, size: _pageSize, sort: '-created_at'),
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: const Color(0xFF1A202C),
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D3748),
              elevation: 0,
              title: const Text(
                'GENESYS PIXELATOR',
                style: TextStyle(
                  color: Color(0xFF4299E1),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.dark_mode_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: AppDrawer(user: widget.user),
            body: Builder(
              builder: (context) {
                final isMobile = MediaQuery.of(context).size.width < 600;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      Text(
                        'Case Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage medical cases, assignments, and workflows',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // BlocBuilder for data-dependent widgets
                      BlocBuilder<CasesCubit, CasesState>(
                        builder: (context, state) {
                          // Use last response for summary cards if loading
                          CasesResponseEntity? responseToUse;
                          bool isLoading = false;

                          if (state is CasesLoaded) {
                            _lastResponse = state.response;
                            responseToUse = state.response;
                          } else if (state is CasesLoading) {
                            isLoading = true;
                            responseToUse = _lastResponse; // Use cached data
                          } else if (state is CasesError) {
                            responseToUse =
                                _lastResponse; // Use cached data on error
                          } else {
                            responseToUse = _lastResponse;
                          }

                          final cases = responseToUse?.cases ?? [];
                          final totalCases = responseToUse?.total ?? 0;
                          final activeCases = _calculateActiveCases(cases);
                          final pendingCases = _calculatePendingCases(cases);
                          final completedCases = _calculateCompletedCases(
                            cases,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Summary Cards - always show
                              CaseSummaryCards(
                                totalCases: totalCases,
                                activeCases: activeCases,
                                pendingCases: pendingCases,
                                completedCases: completedCases,
                              ),
                              const SizedBox(height: 24),
                              // Filters Bar - always show
                              CaseFiltersBar(
                                initialSearchQuery: _searchQuery,
                                selectedPriority: _priorityFilter,
                                onSearchChanged: (query) => _handleSearch(
                                  query,
                                  context.read<CasesCubit>(),
                                ),
                                onPriorityChanged: (priority) =>
                                    _handlePriorityChange(
                                      priority,
                                      context.read<CasesCubit>(),
                                    ),
                                onFiltersTap: _handleFiltersTap,
                              ),
                              const SizedBox(height: 24),
                              // Cases Table - show loading only here
                              if (isLoading && responseToUse == null)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4299E1),
                                      ),
                                    ),
                                  ),
                                )
                              else if (state is CasesError &&
                                  responseToUse == null)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          final cubit = context
                                              .read<CasesCubit>();
                                          _loadCases(cubit);
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              else if (responseToUse != null)
                                CasesTable(
                                  cases: cases,
                                  currentPage: responseToUse.page,
                                  pageSize: responseToUse.size,
                                  totalPages: responseToUse.pages,
                                  onPageChanged: (page) => _handlePageChanged(
                                    page,
                                    context.read<CasesCubit>(),
                                  ),
                                  onPageSizeChanged: (size) =>
                                      _handlePageSizeChanged(
                                        size,
                                        context.read<CasesCubit>(),
                                      ),
                                )
                              else
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF4299E1),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
