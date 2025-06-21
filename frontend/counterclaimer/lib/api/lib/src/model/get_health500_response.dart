//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_health500_response.g.dart';

/// GetHealth500Response
///
/// Properties:
/// * [error] 
@BuiltValue()
abstract class GetHealth500Response implements Built<GetHealth500Response, GetHealth500ResponseBuilder> {
  @BuiltValueField(wireName: r'error')
  String? get error;

  GetHealth500Response._();

  factory GetHealth500Response([void updates(GetHealth500ResponseBuilder b)]) = _$GetHealth500Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetHealth500ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetHealth500Response> get serializer => _$GetHealth500ResponseSerializer();
}

class _$GetHealth500ResponseSerializer implements PrimitiveSerializer<GetHealth500Response> {
  @override
  final Iterable<Type> types = const [GetHealth500Response, _$GetHealth500Response];

  @override
  final String wireName = r'GetHealth500Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetHealth500Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetHealth500Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetHealth500ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.error = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetHealth500Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetHealth500ResponseBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

