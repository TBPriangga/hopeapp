import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes/app_routes.dart';
import '../../../viewsModels/sermon/sermon_viewmodel.dart';
import '../../../models/sermon/sermon_series_model.dart';
import 'package:intl/intl.dart';

class SermonScreen extends StatefulWidget {
  const SermonScreen({super.key});

  @override
  State<SermonScreen> createState() => _SermonScreenState();
}

class _SermonScreenState extends State<SermonScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SermonViewModel>().loadSermonSeries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF132054),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: DatePickerDialog(
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Set tanggal ke awal bulan untuk konsistensi
        _selectedDate = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectMonth(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('MMMM yyyy', 'id_ID')
                              .format(_selectedDate!)
                          : 'Pilih Bulan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
            ),
        ],
      ),
    );
  }

  List<SermonSeries> _filterSeries(List<SermonSeries> series) {
    final query = _searchController.text.toLowerCase();
    var filtered = series;

    // Filter berdasarkan pencarian
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.title.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query);
      }).toList();
    }

    // Filter berdasarkan bulan dan tahun
    if (_selectedDate != null) {
      filtered = filtered.where((s) {
        // Cek apakah bulan dan tahun cocok dengan tanggal mulai atau tanggal berakhir
        bool matchesStartDate = s.startDate.year == _selectedDate!.year &&
            s.startDate.month == _selectedDate!.month;
        bool matchesEndDate = s.endDate != null &&
            s.endDate!.year == _selectedDate!.year &&
            s.endDate!.month == _selectedDate!.month;

        // Cek apakah series berjalan selama bulan yang dipilih
        bool isRunningDuringSeries = s.startDate.isBefore(_selectedDate!) &&
            (s.endDate?.isAfter(_selectedDate!) ?? false);

        return matchesStartDate || matchesEndDate || isRunningDuringSeries;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF132054),
              Color(0xFF2B478A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isSearching
                      ? TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            hintText: 'Cari series khotbah...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false)
                              _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 500),
                              () {
                                setState(() {});
                              },
                            );
                          },
                          autofocus: true,
                        )
                      : const Text(
                          'Series Khotbah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_isSearching) {
                          _searchController.clear();
                        }
                        _isSearching = !_isSearching;
                      });
                    },
                  ),
                ],
              ),
              _buildDateFilter(),
              Expanded(
                child: Consumer<SermonViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoadingSeries) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }

                    if (viewModel.seriesError != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${viewModel.seriesError}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => viewModel.loadSermonSeries(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF132054),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final allSeries = viewModel.sermonSeries;
                    if (allSeries.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada series khotbah tersedia',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final filteredSeries = _filterSeries(allSeries);

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: filteredSeries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedDate != null
                                        ? 'Tidak ada series khotbah\npada bulan ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate!)}'
                                        : 'Tidak ada series khotbah\ndengan kata kunci "${_searchController.text}"',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                if (_searchController.text.isNotEmpty ||
                                    _selectedDate != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Ditemukan ${filteredSeries.length} series',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: () => viewModel.refresh(),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: filteredSeries.length,
                                      itemBuilder: (context, index) {
                                        return _buildSeriesCard(
                                          context,
                                          filteredSeries[index],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesCard(BuildContext context, SermonSeries series) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.sermonSeriesDetail,
            arguments: series.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                series.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF132054),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error_outline),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF132054),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    series.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM yyyy', 'id_ID')
                            .format(series.startDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (series.endDate != null) ...[
                        Text(
                          ' - ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID')
                              .format(series.endDate!),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
