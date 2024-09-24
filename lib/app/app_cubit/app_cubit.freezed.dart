// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() standard,
    required TResult Function(Networks newNetwork) networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? standard,
    TResult? Function(Networks newNetwork)? networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? standard,
    TResult Function(Networks newNetwork)? networkChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Standard value) standard,
    required TResult Function(_NetworkChanged value) networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Standard value)? standard,
    TResult? Function(_NetworkChanged value)? networkChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Standard value)? standard,
    TResult Function(_NetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$StandardImplCopyWith<$Res> {
  factory _$$StandardImplCopyWith(
          _$StandardImpl value, $Res Function(_$StandardImpl) then) =
      __$$StandardImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StandardImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$StandardImpl>
    implements _$$StandardImplCopyWith<$Res> {
  __$$StandardImplCopyWithImpl(
      _$StandardImpl _value, $Res Function(_$StandardImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StandardImpl implements _Standard {
  const _$StandardImpl();

  @override
  String toString() {
    return 'AppState.standard()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StandardImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() standard,
    required TResult Function(Networks newNetwork) networkChanged,
  }) {
    return standard();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? standard,
    TResult? Function(Networks newNetwork)? networkChanged,
  }) {
    return standard?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? standard,
    TResult Function(Networks newNetwork)? networkChanged,
    required TResult orElse(),
  }) {
    if (standard != null) {
      return standard();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Standard value) standard,
    required TResult Function(_NetworkChanged value) networkChanged,
  }) {
    return standard(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Standard value)? standard,
    TResult? Function(_NetworkChanged value)? networkChanged,
  }) {
    return standard?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Standard value)? standard,
    TResult Function(_NetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (standard != null) {
      return standard(this);
    }
    return orElse();
  }
}

abstract class _Standard implements AppState {
  const factory _Standard() = _$StandardImpl;
}

/// @nodoc
abstract class _$$NetworkChangedImplCopyWith<$Res> {
  factory _$$NetworkChangedImplCopyWith(_$NetworkChangedImpl value,
          $Res Function(_$NetworkChangedImpl) then) =
      __$$NetworkChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Networks newNetwork});
}

/// @nodoc
class __$$NetworkChangedImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$NetworkChangedImpl>
    implements _$$NetworkChangedImplCopyWith<$Res> {
  __$$NetworkChangedImplCopyWithImpl(
      _$NetworkChangedImpl _value, $Res Function(_$NetworkChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? newNetwork = null,
  }) {
    return _then(_$NetworkChangedImpl(
      null == newNetwork
          ? _value.newNetwork
          : newNetwork // ignore: cast_nullable_to_non_nullable
              as Networks,
    ));
  }
}

/// @nodoc

class _$NetworkChangedImpl implements _NetworkChanged {
  const _$NetworkChangedImpl(this.newNetwork);

  @override
  final Networks newNetwork;

  @override
  String toString() {
    return 'AppState.networkChanged(newNetwork: $newNetwork)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkChangedImpl &&
            (identical(other.newNetwork, newNetwork) ||
                other.newNetwork == newNetwork));
  }

  @override
  int get hashCode => Object.hash(runtimeType, newNetwork);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkChangedImplCopyWith<_$NetworkChangedImpl> get copyWith =>
      __$$NetworkChangedImplCopyWithImpl<_$NetworkChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() standard,
    required TResult Function(Networks newNetwork) networkChanged,
  }) {
    return networkChanged(newNetwork);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? standard,
    TResult? Function(Networks newNetwork)? networkChanged,
  }) {
    return networkChanged?.call(newNetwork);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? standard,
    TResult Function(Networks newNetwork)? networkChanged,
    required TResult orElse(),
  }) {
    if (networkChanged != null) {
      return networkChanged(newNetwork);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Standard value) standard,
    required TResult Function(_NetworkChanged value) networkChanged,
  }) {
    return networkChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Standard value)? standard,
    TResult? Function(_NetworkChanged value)? networkChanged,
  }) {
    return networkChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Standard value)? standard,
    TResult Function(_NetworkChanged value)? networkChanged,
    required TResult orElse(),
  }) {
    if (networkChanged != null) {
      return networkChanged(this);
    }
    return orElse();
  }
}

abstract class _NetworkChanged implements AppState {
  const factory _NetworkChanged(final Networks newNetwork) =
      _$NetworkChangedImpl;

  Networks get newNetwork;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkChangedImplCopyWith<_$NetworkChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
