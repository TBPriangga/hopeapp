import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/customBottomNav.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedIndex = 3;

  late YoutubePlayerController _youtubeController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _youtubeController = YoutubePlayerController(
      initialVideoId: 'xkOOmwk-BWI',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_onYoutubePlayerStateChange);
  }

  void _onYoutubePlayerStateChange() {
    if (_youtubeController.value.isReady) {
      _isPlayerReady = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/form');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/daily-word-list');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Future<void> _launchYoutubeUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
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
                  'Tentang Kami',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: 'Pengharapan'),
                  Tab(text: 'Pendeta'),
                  Tab(text: 'Sejarah'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPengharapanTab(),
                    _buildPendetaTab(),
                    _buildSejarahTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildPengharapanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWhiteCard(
            'Harapan untuk Semua',
            'Merayakan penebusan dan pengharapan di dalam Kristus secara pribadi maupun komunal serta membagikannya bagi dunia.',
          ),
          const SizedBox(height: 16),
          _buildWhiteCard(
            'Visi',
            '"Sebuah Komunitas yang Menyembah, Membina dan Memperlengkapi Anggota untuk Memberkati Tubuh Kristus dan Suku-suku Bangsa"',
          ),
          const SizedBox(height: 16),
          _buildWhiteCard(
            'Misi',
            '• Menyembah (Meninggikan Allah di dalam Ibadah)\n'
                '• Memuridkan (Memuridkan semua orang secara intensional)\n'
                '• Melayani (Melayani tubuh Kristus dan menjangkau suku-suku bangsa)',
          ),
          const SizedBox(height: 16),
          const Text(
            'Value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildValueImages(),
        ],
      ),
    );
  }

  Widget _buildValueImages() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value1.jpg',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value2.jpg',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value3.jpg',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value4.jpg',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
      ],
    );
  }

  Widget _buildPendetaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset(
                      'assets/images/pendeta.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pdm. Christian Bayu Prakoso, S.Psi., M.Th.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132054),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pdm. Christian Bayu Prakoso saat adalah asisten gembala sidang di Gereja Baptis Indonesia Pengharapan Surabaya sejak Tahun 2022. Menikah dengan Ibu Ayu Wahyuningsih dan dikarunia oleh satu orang putra bernama Pramana Bara Prakoso. Mengawali Pendidikan pada program sarjana psikologi (Universitas Brawijaya), Pdm. Bayu melanjutkan Pendidikan Magister teologi di STT Baptis Indonesia yang berada di Kota Semarang.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSejarahTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Sejarah GBI Pengharapan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132054),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: YoutubePlayer(
                    controller: _youtubeController,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF132054),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFF132054),
                      handleColor: Color(0xFF132054),
                    ),
                    onReady: () {
                      setState(() {
                        _isPlayerReady = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF132054),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildValueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Image.asset('assets/images/value1.png'),
        const SizedBox(height: 12),
        Image.asset('assets/images/value2.png'),
        const SizedBox(height: 12),
        Image.asset('assets/images/value3.png'),
        const SizedBox(height: 12),
        Image.asset('assets/images/value4.png'),
      ],
    );
  }
}
