import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:technical_test_superindo/core/theme/app_colors.dart';
import 'package:technical_test_superindo/core/utils/string_utils.dart';
import 'package:technical_test_superindo/presentation/bloc/member_bloc.dart';
import 'package:technical_test_superindo/presentation/pages/member_form_page.dart';

class MemberListView extends StatelessWidget {
  final bool isSynced;
  const MemberListView({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemberBloc, MemberState>(
      listener: (context, state) {
        if (state.isSyncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.cloud_done, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Data berhasil di-upload'),
                ],
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red[600],
            ),
          );
        }
      },
      builder: (context, state) {
        final members = isSynced ? state.syncedMembers : state.draftMembers;

        if (state.isLoading && members.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSynced ? Icons.cloud_done_outlined : Icons.folder_open,
                    size: 72,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada data',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      isSynced
                          ? 'Belum ada data yang sudah di-upload'
                          : 'Klik "Tambah Data" untuk menambahkan data calon anggota',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSynced ? 'Data yang sudah di-upload' : 'List Draft KTA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSynced
                          ? 'Data-data ini sudah dikirimkan ke admin verifikator.'
                          : 'Upload untuk mengirimkan data ini ke admin untuk di-verifikasi.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (!isSynced) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC5CAE9)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Color(0xFF3F51B5)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Data di bawah ini tersimpan secara lokal. Silahkan klik upload semua untuk sinkronisasi.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF3F51B5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                );
              }

              final member = members[index - 1];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Index Number
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // KTP Thumbnail
                          _buildKtpThumbnail(member.ktpPath, member.ktpUrl),
                          const SizedBox(width: 12),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSynced ? StringUtils.maskText(member.nik, 3, 3) : member.nik,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSynced ? StringUtils.maskText(member.phone, 4, 3) : member.phone,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          _buildStatusBadge(isSynced),
                        ],
                      ),
                    ),
                    if (!isSynced) ...[
                      const Divider(height: 1),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberFormPage(member: member),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(width: 1, height: 24, color: Colors.grey[200]),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                context.read<MemberBloc>().add(SyncMember(member));
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.file_upload_outlined, size: 18, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Upload',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
      },
    );
  }

  Widget _buildKtpThumbnail(String? ktpPath, String? ktpUrl) {
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grey300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _buildImage(ktpPath, ktpUrl),
      ),
    );
  }

  Widget _buildImage(String? ktpPath, String? ktpUrl) {
    // 1. Try local file
    if (ktpPath != null && File(ktpPath).existsSync()) {
      return Image.file(
        File(ktpPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildNetworkImage(ktpUrl),
      );
    }
    
    // 2. Try network URL
    return _buildNetworkImage(ktpUrl);
  }

  Widget _buildNetworkImage(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _defaultThumbnailIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }
    return _defaultThumbnailIcon();
  }

  Widget _defaultThumbnailIcon() {
    return const Icon(Icons.image_outlined, size: 16, color: AppColors.textGrey);
  }

  Widget _buildStatusBadge(bool synced) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: synced ? AppColors.syncedBadgeBg : AppColors.draftBadgeBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        synced ? 'Sudah Di-upload' : 'Draft',
        style: TextStyle(
          color: synced ? AppColors.success : AppColors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
