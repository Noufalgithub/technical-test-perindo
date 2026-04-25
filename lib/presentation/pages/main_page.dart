import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      if (_tabController.indexIsChanging) {
        context.read<MemberBloc>().add(FetchMembers(isSynced: _tabController.index == 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.badge_outlined, color: Color(0xFF2C3E50)),
            const SizedBox(width: 8),
            const Text('Register Offline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(Icons.account_circle_outlined, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberFormPage())),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Data'),
            ),
            const SizedBox(height: 8),
            BlocBuilder<MemberBloc, MemberState>(
              builder: (context, state) {
                bool hasDrafts = false;
                if (state is MemberLoaded && _tabController.index == 0) {
                  hasDrafts = state.members.isNotEmpty;
                }
                return OutlinedButton.icon(
                  onPressed: hasDrafts ? () => _showSyncDialog(context) : null,
                  icon: const Icon(Icons.upload),
                  label: Text('Upload Semua${(hasDrafts && state is MemberLoaded) ? ' (${state.members.length})' : ''}'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}
