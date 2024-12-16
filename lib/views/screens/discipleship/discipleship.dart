import 'package:flutter/material.dart';

import '../../../models/discipleship/discipleship_model.dart';

class DiscipleshipClassScreen extends StatefulWidget {
  const DiscipleshipClassScreen({super.key});

  @override
  State<DiscipleshipClassScreen> createState() =>
      _DiscipleshipClassScreenState();
}

class _DiscipleshipClassScreenState extends State<DiscipleshipClassScreen> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Semua',
    'Anak',
    'Remaja-Pemuda',
    'Dewasa Muda',
    'Dewasa Senior',
  ];

  final List<DiscipleshipClassModel> _classes = [
    DiscipleshipClassModel(
      id: '1',
      name: 'Kelas Alkitab Anak',
      category: 'Anak',
      description: 'Pembelajaran Alkitab untuk anak usia 7-12 tahun',
      schedule: 'Minggu, 09:00 WIB',
      mentor: 'Ibu Sarah',
      mentorPhoto: 'https://example.com/photos/mentor1.jpg',
      location: 'Ruang Kelas 1',
    ),
    DiscipleshipClassModel(
      id: '2',
      name: 'Youth Bible Study',
      category: 'Remaja-Pemuda',
      description: 'Pembelajaran Alkitab untuk remaja usia 13-16 tahun',
      schedule: 'Sabtu, 16:00 WIB',
      mentor: 'Kak David',
      mentorPhoto: 'https://example.com/photos/mentor2.jpg',
      location: 'Ruang Remaja',
    ),
    // ... more classes
  ];

  List<DiscipleshipClassModel> get filteredClasses {
    if (_selectedCategory == null || _selectedCategory == 'Semua') {
      return _classes;
    }
    return _classes.where((c) => c.category == _selectedCategory).toList();
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
                title: const Text(
                  'Kelas Pemuridan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Category Filter
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory ||
                        (category == 'Semua' && _selectedCategory == null);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        backgroundColor: Colors.black.withOpacity(0.1),
                        selectedColor: Colors.white,
                        checkmarkColor: const Color(0xFF132054),
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF132054)
                                : Colors.black,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              // Class List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredClasses.length,
                  itemBuilder: (context, index) {
                    final classData = filteredClasses[index];
                    return _buildClassCard(classData);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(DiscipleshipClassModel classData) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with Category
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: classData.categoryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  classData.categoryIcon,
                  color: classData.categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  classData.category,
                  style: TextStyle(
                    color: classData.categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132054),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  classData.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Mentor Section with Photo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          classData.mentorPhoto,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pembimbing',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              classData.mentor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF132054),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Schedule and Location
                _buildInfoRow(Icons.schedule, 'Jadwal', classData.schedule),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'Lokasi', classData.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
