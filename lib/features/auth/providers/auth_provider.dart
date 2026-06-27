// Feature-level auth provider — re-exports the shared auth provider
// so feature code can import from within the auth feature folder.
// All actual auth logic lives in lib/shared/providers/auth_provider.dart.

export '../../../shared/providers/auth_provider.dart';