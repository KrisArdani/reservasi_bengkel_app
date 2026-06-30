// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CustomerController)
final customerControllerProvider = CustomerControllerProvider._();

final class CustomerControllerProvider
    extends $NotifierProvider<CustomerController, CustomerState> {
  CustomerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerControllerHash();

  @$internal
  @override
  CustomerController create() => CustomerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomerState>(value),
    );
  }
}

String _$customerControllerHash() =>
    r'299327bfaa73762d1ce11655f5c81735bd954feb';

abstract class _$CustomerController extends $Notifier<CustomerState> {
  CustomerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CustomerState, CustomerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CustomerState, CustomerState>,
              CustomerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
