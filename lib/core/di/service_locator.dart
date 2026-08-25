import '../network/api_client.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/loads/data/load_repository.dart';
import '../../features/offers/data/offer_repository.dart';
import '../../features/shipment/data/shipment_repository.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/profile/data/user_repository.dart';
import '../../features/vehicles/data/vehicle_repository.dart';
import '../../features/companies/data/company_repository.dart';
import '../../features/companies/data/company_lookup_repository.dart';
import '../../features/notifications/data/notification_repository.dart';

class ServiceLocator {
  ServiceLocator._();

  static final instance = ServiceLocator._();

  late final ApiClient apiClient;
  late final AuthRepository authRepository;
  late final LoadRepository loadRepository;
  late final OfferRepository offerRepository;
  late final ShipmentRepository shipmentRepository;
  late final ChatRepository chatRepository;
  late final UserRepository userRepository;
  late final VehicleRepository vehicleRepository;
  late final CompanyRepository companyRepository;
  late final CompanyLookupRepository companyLookupRepository;
  late final NotificationRepository notificationRepository;

  void init() {
    apiClient = ApiClient();
    authRepository = AuthRepository(apiClient);
    loadRepository = LoadRepository(apiClient);
    offerRepository = OfferRepository(apiClient);
    shipmentRepository = ShipmentRepository(apiClient);
    chatRepository = ChatRepository(apiClient);
    userRepository = UserRepository(apiClient);
    vehicleRepository = VehicleRepository(apiClient);
    companyRepository = CompanyRepository(apiClient);
    // Tashqi reyestr xizmati — apiClient'dan foydalanmaydi.
    companyLookupRepository = CompanyLookupRepository();
    notificationRepository = NotificationRepository(apiClient);
  }
}

final sl = ServiceLocator.instance;
