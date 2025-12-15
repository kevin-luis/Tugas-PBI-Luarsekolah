// lib/features/home/domain/usecases/get_subscriptions_use_case.dart

import '../entities/subscription_entity.dart';
import '../repositories/home_repository.dart';

class GetSubscriptionsUseCase {
  final HomeRepository repository;

  GetSubscriptionsUseCase(this.repository);

  Future<List<SubscriptionEntity>> call() async {
    return await repository.getSubscriptions();
  }
}