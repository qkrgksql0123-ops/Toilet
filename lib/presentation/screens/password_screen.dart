import 'package:flutter/material.dart';
import 'package:bol_il_bwa/presentation/theme/app_theme.dart';
import 'package:bol_il_bwa/presentation/widgets/password_card.dart';
import 'package:bol_il_bwa/data/mock/mock_data.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _toiletSearchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedToiletId;

  @override
  void dispose() {
    _toiletSearchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitPassword() {
    if (_selectedToiletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('화장실을 선택해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호를 입력해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('비밀번호가 공유되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );

    _toiletSearchController.clear();
    _passwordController.clear();
    setState(() {
      _selectedToiletId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockedToilets =
        MockData.toilets.where((t) => t.isLocked).toList();
    final selectedToilet = _selectedToiletId != null
        ? MockData.getToiletById(_selectedToiletId!)
        : null;
    final passwordsForSelected = _selectedToiletId != null
        ? MockData.getPasswordsForToilet(_selectedToiletId!)
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('비번 공유'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '잠긴 화장실 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text: selectedToilet?.name ?? '',
                ),
                onTap: () {
                  _showToiletPicker(context, lockedToilets);
                },
                decoration: InputDecoration(
                  hintText: '화장실을 선택하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.surfaceColor,
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              if (selectedToilet != null) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppTheme.surfaceColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedToilet.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedToilet.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                '비밀번호 입력',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '예: 1234',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.surfaceColor,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '공유하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (selectedToilet != null) ...[
                Text(
                  '공유된 비밀번호 (${passwordsForSelected.length}개)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (passwordsForSelected.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        '공유된 비밀번호가 없습니다',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...passwordsForSelected.map((pw) {
                    return PasswordCard(
                      passwordShare: pw,
                      onLikePressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('좋아요가 추가되었습니다'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showToiletPicker(
      BuildContext context, List<dynamic> lockedToilets) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: ListView.builder(
            itemCount: lockedToilets.length,
            itemBuilder: (context, index) {
              final toilet = lockedToilets[index];
              return ListTile(
                leading: const Icon(Icons.lock),
                title: Text(toilet.name),
                subtitle: Text(toilet.address),
                onTap: () {
                  setState(() {
                    _selectedToiletId = toilet.id;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
