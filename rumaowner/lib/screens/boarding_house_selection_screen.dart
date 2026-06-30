import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../widgets/owner_widgets.dart';
import 'property_detail_screen.dart';

class BoardingHouseSelectionScreen extends StatefulWidget {
  const BoardingHouseSelectionScreen({super.key});

  @override
  State<BoardingHouseSelectionScreen> createState() => _BoardingHouseSelectionScreenState();
}

class _BoardingHouseSelectionScreenState extends State<BoardingHouseSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<BoardingHouseProvider>().fetchBoardingHouses();
      }
    });
  }

  void _openAddBoardingHouse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PropertyDetailScreen()),
    );
  }

  void _logout() {
    context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final bhProvider = context.watch<BoardingHouseProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final ownerName = user?.name.isNotEmpty == true ? user!.name : 'Owner';

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      appBar: AppBar(
        title: const Text('Pilih Kos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.accent),
            tooltip: 'Keluar Akun',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => bhProvider.fetchBoardingHouses(),
          color: AppTheme.darkOlive,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selamat Datang kembali,',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  ownerName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Silakan pilih rumah kos yang ingin Anda kelola hari ini:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 24),
                if (bhProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.darkOlive,
                      ),
                    ),
                  )
                else if (bhProvider.boardingHouses.isEmpty)
                  OwnerPanel(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum Ada Kos Terdaftar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Anda harus menambahkan kosan pertama Anda untuk mulai mengelola kamar dan penghuni.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _openAddBoardingHouse,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Tambah Kosan Pertama'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bhProvider.boardingHouses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final house = bhProvider.boardingHouses[index];
                          final imageUrl = house.imageUrl.isNotEmpty
                              ? house.imageUrl
                              : 'https://picsum.photos/seed/${house.name}/500/360';
                          final roomsCount = house.totalRooms;
                          final vacantCount = house.vacantRooms;

                          return GestureDetector(
                            onTap: () {
                              bhProvider.selectBoardingHouse(house);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cardWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: OwnerImageFrame(
                                        imageData: imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              house.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.textDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                  color: AppTheme.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    house.address,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.statusBlueBg,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    '$roomsCount Kamar',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppTheme.statusBlueText,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.statusGreenBg,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    '$vacantCount Kosong',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppTheme.statusGreenText,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Center(
                                        child: Icon(
                                          Icons.chevron_right,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _openAddBoardingHouse,
                        icon: const Icon(Icons.add, color: AppTheme.darkOlive),
                        label: const Text('Tambah Kosan Baru'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.darkOlive, width: 1.5),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
