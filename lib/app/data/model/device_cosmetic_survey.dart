/// Model quản lý kết quả khảo sát tình trạng ngoại quan sơ bộ của khách hàng
enum BodyCondition {
  pristine(
    id: 'pristine',
    label: 'Như mới (99%)',
    description: 'Thân viền đẹp hoàn hảo, không trầy xước',
    priceMultiplier: 1.0,
  ),
  minorScratches(
    id: 'minor_scratches',
    label: 'Trầy xước nhẹ (95%)',
    description: 'Có vết xước dăm nhỏ theo thời gian sử dụng',
    priceMultiplier: 0.95,
  ),
  dented(
    id: 'dented',
    label: 'Cấn móp / Trầy nhiều',
    description: 'Có vết cấn góc, móp viền hoặc xước sâu',
    priceMultiplier: 0.85,
  );

  final String id;
  final String label;
  final String description;
  final double priceMultiplier;

  const BodyCondition({
    required this.id,
    required this.label,
    required this.description,
    required this.priceMultiplier,
  });
}

enum ScreenCondition {
  flawless(
    id: 'flawless',
    label: 'Hoàn hảo',
    description: 'Mặt kính sáng đẹp nguyên bản, không trầy xước',
    priceMultiplier: 1.0,
  ),
  scratched(
    id: 'scratched',
    label: 'Trầy xước nhẹ',
    description: 'Xước dăm lông mèo, hiển thị bình thường',
    priceMultiplier: 0.93,
  ),
  cracked(
    id: 'cracked',
    label: 'Nứt vỡ kính',
    description: 'Có vết nứt hoặc rạn kính ngoài (cần ép lại kính)',
    priceMultiplier: 0.75,
  );

  final String id;
  final String label;
  final String description;
  final double priceMultiplier;

  const ScreenCondition({
    required this.id,
    required this.label,
    required this.description,
    required this.priceMultiplier,
  });
}

enum AccountStatus {
  readyToLogOut(
    id: 'ready',
    label: 'Đã sẵn sàng đăng xuất',
    description: 'Chủ sở hữu máy, có thể thoát iCloud / Google Account ngay tại quầy',
    isEligible: true,
  ),
  lockedOrForgotten(
    id: 'locked',
    label: 'Quên mật khẩu / Chưa rõ',
    description: 'Cần hỗ trợ lấy lại mật khẩu trước khi thu cũ',
    isEligible: false,
  );

  final String id;
  final String label;
  final String description;
  final bool isEligible;

  const AccountStatus({
    required this.id,
    required this.label,
    required this.description,
    required this.isEligible,
  });
}

class DeviceCosmeticSurvey {
  BodyCondition body;
  ScreenCondition screen;
  AccountStatus account;

  DeviceCosmeticSurvey({
    this.body = BodyCondition.pristine,
    this.screen = ScreenCondition.flawless,
    this.account = AccountStatus.readyToLogOut,
  });

  double get totalMultiplier => body.priceMultiplier * screen.priceMultiplier;
}
