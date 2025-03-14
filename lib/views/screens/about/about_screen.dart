import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/utils/youtube_helper.dart';
import '../../widgets/customBottomNav.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _selectedIndex = 3;
  WebViewController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    final videoId = YouTubeHelper.extractVideoId(
        'https://www.youtube.com/watch?v=xkOOmwk-BWI');
    if (videoId == null) return;

    _youtubeController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { 
              margin: 0; 
              overflow: hidden;
              border-radius: 12px;
            }
            .video-container {
              position: relative;
              padding-bottom: 56.25%;
              height: 0;
              overflow: hidden;
              border-radius: 12px;
            }
            .video-container iframe {
              position: absolute;
              top: 0;
              left: 0;
              width: 100%;
              height: 100%;
              border-radius: 12px;
              border: none;
            }
          </style>
        </head>
        <body>
          <div class="video-container">
            <iframe 
              src="https://www.youtube.com/embed/$videoId"
              frameborder="0"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowfullscreen>
            </iframe>
          </div>
        </body>
      </html>
    ''');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController?.clearCache();
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
                  Tab(text: 'Cabang')
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPengharapanTab(),
                    _buildPendetaTab(),
                    _buildSejarahTab(),
                    _buildGerejaCabangTab(),
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
            'assets/images/value1.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value2.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value3.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/value4.png',
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
          // Video Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Sejarah GBI Pengharapan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF132054),
                  ),
                ),
                const SizedBox(height: 16),
                if (_youtubeController != null)
                  Container(
                    height: 220,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: WebViewWidget(
                      controller: _youtubeController!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timeline Section
          _buildTimelineSection(
            title: 'Fase Awal Perintisan (1952-1955)',
            content:
                'Perintisan GBI Pengharapan Surabaya dimulai pada tanggal 12 Februari 1952 di Jl. Anwari 12A Surabaya. Setahun setelahnya, pelayanan Sekolah Minggu resmi dibuka dalam empat bahasa yaitu, Belanda, Indonesia, Mandarin, dan Inggris dan dilayani oleh Nona Wilma Weeks dan Pdt. Stockwell. Sedangkan mulai tahun 1955 barulah dimulai ibadah di tempat tersebut yang dilayani oleh Pdt. P.F. Watimuri.',
            isFirst: true,
          ),

          _buildTimelineSection(
            title: 'Penggembalaan Pdt. P.F. Watimuri (1956-1984)',
            content:
                'Seiring bertambah banyaknya anggota yang hadir, maka Misi Baptis membeli tanah di Jl. Pandegiling 213A Surabaya. Pada Bulan April 1958, Gedung gereja di Jl. Pandegiling 213A yang digembalakan oleh Pdt. P. F. Watimuri. Pada tanggal 5 April 1959 Gereja Baptis Pengharapan Surabaya resmi diorganisasikan dengan 62 orang yang menandatangani piagam pengorganisasian. Dan pada saat Kongres 2 gereja-gereja Baptis Indonesia 1976, Gereja Baptis Pengharapan berubah nama menjadi Gereja Baptis Indonesia Pengharapan Surabaya. Pada tanggal 1981, Pdt. P.F Watimuri meninggal dunia dan meninggalkan jemaat yang sudah 26 tahun dilayaninya. Dan gereja mengalami kekosongan selama 3 tahun.',
          ),

          _buildTimelineSection(
            title: 'Penggembalaan Pdt. Em. Imanuel Suparman (1985-2007)',
            content:
                'Pada tanggal 1 Januari 1985 gereja resmi memiliki gembala sidang yang baru. Beliau adalah Pdt. Imanuel Suparman yang sebelumnya melayani di GBI Getsemani Jakarta. Diawali dengan pelayanan KPW yang terdiri dari 12 kelompok dan Pos Pemberitaan Injil di daerah Bronggalan yang akhirnya menjadi GBI Duta Harapan, Pos Pemberitaan Injil di daerah Putat Jaya yang akhirnya menjadi GBI Putat Jaya, serta Pos Pemberitaan Injil di daerah Mojolebak yang saat ini menjadi GBI Pengharapan Cab. Balongpanggang. Hingga pada tahun 2005, Pdt. Em. Imanuel Suparman mengakhiri jabatan strukturalnya sebagai gembala sidang. Gereja kembali mengalami kekosongan gembala sidang selama 3 tahun.',
          ),

          _buildTimelineSection(
            title: 'Penggembalaan Pdt. Em. Dwi Hari Santoso (2008-2024)',
            content:
                'Pada tanggal 5 Januari 2008 gereja resmi memiliki gembala sidang yang baru. Beliau adalah Pdt. Dwi Hari Santoso yang sebelumnya melayani di GBI Karunia Roh Kudus Lampung. Berbagai macam pelayanan yang menjawab kebutuhan terus dilakukan demi pertumbuhan iman jemaat. Hingga pada tahun 2017 gereja mulai memikirkan dengan serius tentang sistem management gereja yang pada akhirnya tercetuslah "Simple Church" yang menjadi pedoman untuk membawa seluruh jemaat untuk mengasihi Allah melalui ibadah, mengasihi sesama melalui pemuridan, dan melayani tubuh Kristus melalui setiap talenta yang diberikan serta menjangkau suku-suku banga melalui semangat dalam penginjilan. Pada 1 Januari 2022 GBI pengharapan Surabaya mengangkat Pdm. Christian Bayu Prakoso untuk menjadi asisten Gembala Sidang Bidang Pendidikan. Hal ini dimaksudkan supaya pemuridan yang merupakan jantung dari pergerakan pelayanan di GBI Pengharapan Surabaya dapat lebih bertumbuh dan berkembang. Pada Bulan April 2024, Pdt. Em. Dwi Hari Santoso resmi mengakhiri jabatan strukturalnya sebagai gembala sidang. Setelah melalui pergumulan yang panjang GBI Pengharapan Surabaya akhirnya mengundang Pdm. Christian Bayu Prakoso untuk menjadi gembala sidang. Dan Pdm. Christian Bayu Prakoso telah memberikan jawaban atas panggilan itu dengan bersedia melayani sebagai gembala sidang mulai 1 Januari 2026.',
            isLast: true,
          ),

          const SizedBox(height: 10),

          // Closing Statement
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF132054),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Kiranya melalui sejarah GBI pengharapan Surabaya, kita semakin dapat memahami betapa baik dan kasihnya Allah kita yang telah memulai dan terus memelihara gerejanya hingga saat ini dan sampai selamanya.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Soli Deo Gloria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[100],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection({
    required String title,
    required String content,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF132054),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFF132054),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
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

  Widget _buildGerejaCabangTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gereja Cabang',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'GBI Pengharapan telah berkembang dengan beberapa cabang yang tersebar di berbagai wilayah',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),

          // Balongpanggang
          _buildChurchBranchCard(
            name: 'GBI Pengharapan Cab. Balongpanggang',
            pastor: 'Pdt. Yunus Sujilan',
            address:
                'RT 01, RW 03 dusun mojolebak, desa mojogede, kec. Balongpanggang, kab. Gresik.',
            city: 'Gresik',
            province: 'Jawa Timur',
          ),

          // Jelau Belangiran
          _buildChurchBranchCard(
            name: 'GBI Pengharapan Cab. Jelau Belangiran',
            pastor: 'Pdm. Marthen Lodowick',
            address:
                'Dusun Jelau Belangiran. RT.002/RW.001, Desa Pak Mayam. Kec. Ngabang. Kab. Landak.',
            city: 'Landak',
            province: 'Kalimantan Barat',
          ),

          // BPW Lingga
          _buildChurchBranchCard(
            name: 'GBI Pengharapan BPW Lingga',
            pastor: 'Pdt. Zakaria Tubi',
            address:
                'RT : 007 , RW 014 Desa Lingga, Kecamatan Sungai Ambawang. Kabupaten Kubu Raya.',
            city: 'Kubu Raya',
            province: 'Kalimantan Barat',
          ),

          // BPW Laman Tongon
          _buildChurchBranchCard(
            name: 'GBI Pengharapan BPW Laman Tongon',
            pastor: 'Bp. Apri Nyoman',
            address:
                'RT 008, RW OO3 Desa Balai Poluntan, Kecamatan Jelimpo, Kabupaten Landak.',
            city: 'Landak',
            province: 'Kalimantan Barat',
          ),
        ],
      ),
    );
  }

  Widget _buildChurchBranchCard({
    required String name,
    required String pastor,
    required String address,
    required String city,
    required String province,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF132054),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.church,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pastor Info
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Color(0xFF132054),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gembala Sidang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            pastor,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF132054),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alamat',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            address,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  city,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                province,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
