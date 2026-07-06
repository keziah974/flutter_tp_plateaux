import 'package:flutter_test/flutter_test.dart';
import 'package:game_board/core/constants/app_constants.dart';

void main() {
  test('app name constant is set', () {
    expect(AppConstants.appName, 'Game Board');
  });
}
