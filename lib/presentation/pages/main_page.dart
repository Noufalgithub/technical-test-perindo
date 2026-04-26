import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:technical_test_superindo/core/theme/app_colors.dart';
import 'package:technical_test_superindo/presentation/bloc/member_bloc.dart';
import 'package:technical_test_superindo/presentation/bloc/profile_bloc.dart';
import 'package:technical_test_superindo/presentation/pages/member_form_page.dart';
import 'package:technical_test_superindo/presentation/pages/profile_page.dart';
import 'package:technical_test_superindo/presentation/widgets/member_list_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProfileBloc>().add(FetchProfile());
    context.read<MemberBloc>().add(const FetchMembers(isSynced: false));
    
    _tabController.addListener(() {
      setState(() {});
      if (_tabController.indexIsChanging) {
        context.read<MemberBloc>().add(FetchMembers(isSynced: _tabController.index == 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            const Icon(Icons.badge_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Register Offline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                String name = 'User';
                if (state is ProfileLoaded) {
                  name = state.userData['full_name'] ?? 'User';
                }
                return InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Text(
                          name.split(' ').first,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.account_circle,
                          size: 18,
                          color: Color(0xFF2B3A67),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: 'Hapus Semua Draft',
              onPressed: () => _showClearDatabaseDialog(context),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2B3A67),
          indicatorWeight: 3,
          labelColor: const Color(0xFF2B3A67),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Draft'),
            Tab(text: 'Sudah Di-Upload'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MemberListView(isSynced: false),
          MemberListView(isSynced: true),
        ],
      ),
      bottomNavigationBar: _tabController.index == 1 
        ? null 
        : Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberFormPage())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B3A67),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Tambah Data', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<MemberBloc, MemberState>(
              builder: (context, state) {
                final drafts = state.draftMembers;
                bool hasDrafts = drafts.isNotEmpty;
                int draftCount = drafts.length;
                return OutlinedButton(
                  onPressed: hasDrafts ? () => _showSyncDialog(context) : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    side: BorderSide(color: hasDrafts ? const Color(0xFF2B3A67) : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload_outlined, size: 20, color: hasDrafts ? const Color(0xFF2B3A67) : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Semua${hasDrafts ? ' ($draftCount)' : ''}',
                        style: TextStyle(
                          color: hasDrafts ? const Color(0xFF2B3A67) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Upload Semua Data')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Apakah kamu yakin ingin upload semua data?', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'Pastikan kamu sudah mengisi semua data dengan benar, ya!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MemberBloc>().add(SyncAllMembers());
            },
            child: const Text('Ya, Upload Semua'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Batal'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  void _showClearDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Semua data draft lokal akan dihapus secara permanen. Data yang sudah di-upload tidak akan terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MemberBloc>().add(DeleteAllMembers());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
