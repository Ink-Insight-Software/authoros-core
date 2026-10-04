/// The other half of the webhook: a checkout that names who is buying.
///
/// `supabase/functions/lemon-squeezy-webhook/` refuses any purchase whose body
/// carries no account — there is nothing to grant to, and guessing from the
/// billing email would attach a purchase to whoever happened to share that
/// address. This is the end that has to put the account there in the first
/// place, so the two refusals are the same refusal seen from either side.
///
/// Pure, and deliberately so: it builds a URL and knows nothing about opening
/// one. That keeps it testable without a browser, a network or a session, and
/// keeps `lib/core/` free of Flutter — the same reason `record_write_sink.dart`
/// declares a port rather than importing the sync layer.
library;

import 'entitlement.dart';

/// Where the store lives, and which variant sells what.
///
/// Configured at build time rather than compiled in, like the Supabase
/// credentials beside them, because the ids differ between a test store and
/// the real one and neither belongs in the repository.
///
/// The default is empty and means **nothing is for sale**, which is true until
/// a store exists. A build that has not been told the ids offers no purchase
/// rather than a link to a page that cannot pay.
class CheckoutStore {
  const CheckoutStore({
    required this.baseUrl,
    required this.variants,
    this.sellableCodes = const <String>{},
  });

  /// A store that sells exactly [codes], with no Lemon Squeezy configuration.
  ///
  /// What the Stripe catalogue produces. It carries no [baseUrl] because the
  /// Stripe path does not build URLs here — `stripe-checkout` does, from a
  /// row — and inventing one would make [checkoutUrlFor] answer for a product
  /// it cannot actually link to.
  const CheckoutStore.selling(Set<String> codes)
      : baseUrl = '',
        variants = const <String, String>{},
        sellableCodes = codes;

  /// Reads `LEMON_SQUEEZY_CHECKOUT_URL` and `LEMON_SQUEEZY_CHECKOUT_VARIANTS`.
  ///
  /// Variants are `product-id:slug` pairs — the mirror of the environment the
  /// webhook parses, written the same way so the two are read together.
  factory CheckoutStore.fromEnvironment() {
    const raw = String.fromEnvironment('LEMON_SQUEEZY_CHECKOUT_VARIANTS');
    final variants = <String, String>{};
    for (final pair in raw.split(',')) {
      final parts = pair.split(':');
      if (parts.length != 2) continue;
      final product = parts[0].trim();
      final slug = parts[1].trim();
      if (product.isEmpty || slug.isEmpty) continue;
      variants[product] = slug;
    }
    return CheckoutStore(
      baseUrl: const String.fromEnvironment('LEMON_SQUEEZY_CHECKOUT_URL'),
      variants: variants,
    );
  }

  /// The store's checkout root, e.g. `https://inkinsight.lemonsqueezy.com/buy`.
  final String baseUrl;

  /// Wire product id to the store's checkout slug for it.
  ///
  /// **The Lemon Squeezy half, and it is retired.**
  /// [ADR-0019](../../docs/architecture/ADR-0019-stripe-is-the-sole-entitlement-authority.md)
  /// made Stripe the sole authority on September 14, 2026, and the function
  /// these slugs addressed went with it. Kept because a build may still be
  /// configured this way and a gate that forgot how to read its own
  /// configuration would open a paid room; [sellableCodes] is where new
  /// selling is declared.
  final Map<String, String> variants;

  /// Product codes this build can sell, independent of any slug.
  ///
  /// **The Stripe half.** `stripe-checkout` sells a `curio_products` row to a
  /// signed-in account: it takes a `productCode`, looks the row up, and
  /// refuses anything inactive or without a `stripe_price_id`. There is no
  /// slug and no store URL in that path, so a set of codes is the whole of
  /// what "on sale" means now, and `CheckoutCatalogue` is what fills it.
  ///
  /// Empty by default, which keeps the old rule intact: a build that has not
  /// been told what it sells sells nothing.
  final Set<String> sellableCodes;

  bool get sellsAnything =>
      sellableCodes.isNotEmpty || (baseUrl.isNotEmpty && variants.isNotEmpty);

  /// Whether [product] can be bought from this build.
  ///
  /// Either half may answer yes and neither may be assumed. A product with no
  /// slug and no catalogue row is not for sale here — the same rule the
  /// purchase path applies in the other direction, where an unmapped product
  /// grants nothing rather than guessing.
  bool sells(PaidProduct product) =>
      sellableCodes.contains(product.id) ||
      (baseUrl.isNotEmpty && (variants[product.id]?.isNotEmpty ?? false));
}

/// The store every gate reads when it was not handed one.
///
/// Mutable, and that is the point: what a build sells is no longer knowable at
/// compile time. The Stripe catalogue is a table, so it arrives after start-up,
/// and the gates have to be able to learn about it — see `CheckoutCatalogue`.
///
/// It starts as [CheckoutStore.fromEnvironment] so a build configured the old
/// way behaves exactly as it did before anything is loaded, and so a build with
/// no network still has an answer. Tests pass their own store to a gate's
/// constructor and never touch this.
CheckoutStore appCheckoutStore = CheckoutStore.fromEnvironment();

/// Builds the checkout URL for [product], or null when it cannot be bought.
///
/// Null, never a partial link. There are three ways to get nothing, and all of
/// them are cases where sending someone to a payment page would be worse than
/// showing no button at all:
///
///   * **No account.** The webhook will refuse the purchase, so the money
///     would be taken and nothing granted. This is the important one.
///   * **No store configured**, which is true of every build until one exists.
///   * **A product this store does not sell.**
///
/// The account travels as `checkout[custom][user_id]`, which the provider
/// echoes back in `meta.custom_data.user_id` — exactly where the function
/// reads it.
Uri? checkoutUrlFor(
  PaidProduct product, {
  required CheckoutStore store,
  required String? userId,
}) {
  final slug = store.variants[product.id];
  if (store.baseUrl.isEmpty || slug == null || slug.isEmpty) return null;

  final account = userId?.trim() ?? '';
  if (account.isEmpty) return null;

  final root = store.baseUrl.endsWith('/')
      ? store.baseUrl.substring(0, store.baseUrl.length - 1)
      : store.baseUrl;

  return Uri.parse('$root/$slug').replace(queryParameters: {
    'checkout[custom][user_id]': account,
  });
}
