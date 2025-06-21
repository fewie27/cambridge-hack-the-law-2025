//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'add_case_request.g.dart';

/// AddCaseRequest
///
/// Properties:
/// * [userPrompt] - The user prompt to analyze
@BuiltValue()
abstract class AddCaseRequest implements Built<AddCaseRequest, AddCaseRequestBuilder> {
  /// The user prompt to analyze
  @BuiltValueField(wireName: r'user_prompt')
  String get userPrompt;

  AddCaseRequest._();

  factory AddCaseRequest([void updates(AddCaseRequestBuilder b)]) = _$AddCaseRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AddCaseRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AddCaseRequest> get serializer => _$AddCaseRequestSerializer();
}

class _$AddCaseRequestSerializer implements PrimitiveSerializer<AddCaseRequest> {
  @override
  final Iterable<Type> types = const [AddCaseRequest, _$AddCaseRequest];

  @override
  final String wireName = r'AddCaseRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AddCaseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_prompt';
    yield serializers.serialize(
      object.userPrompt,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AddCaseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AddCaseRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_prompt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userPrompt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AddCaseRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AddCaseRequestBuilder();
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

