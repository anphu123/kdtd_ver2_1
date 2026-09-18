/// FunctionAttribute - Định danh thuộc tính chức năng trong hệ thống & DB
enum FunctionAttribute {
  wifi('WIFI'),
  bluetooth('BLUE_TOOTH'),
  location('GPS'),
  vibration('VIBRATION'),
  biometrics('BIOMETRICS'),
  mic('MIC'),
  volumeUp('VOLUME_UP'),
  volumeDown('VOLUME_DOWN'),
  frontCamera('FRONT_CAMERA'),
  rearCamera('BACK_CAMERA'),
  externalSpeaker('SPEAKER'),
  internalSpeaker('HEADPHONE'),
  touchScreen('TOUCH_SCREEN');

  const FunctionAttribute(this.dbCode);
  final String dbCode;
}
