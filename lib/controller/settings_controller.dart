import 'package:family_locator/utils/offline_data.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Observable variable to track the radio button selection
  RxInt locationHistoryOption = 0.obs; // Default value (0 for Off, 1 for On)

  @override
  void onInit() {
    super.onInit();
    getTPR();
  }

  getTPR() async {
    locationHistoryOption.value =
        int.parse(await OfflineData.getData("isTPR") ?? "0");
  }

  // Function to update the selected option
  void setLocationHistoryOption(int? value) {
    if (value != null) {
      locationHistoryOption.value = value;
      OfflineData.setData(
          "isTPR", locationHistoryOption.value.toString(), true);
    }
  }
}
