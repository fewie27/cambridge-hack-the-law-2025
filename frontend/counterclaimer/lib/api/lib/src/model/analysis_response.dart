//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:my_flutter_api_client/src/model/argument.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'analysis_response.g.dart';

/// AnalysisResponse
///
/// Properties:
/// * [caseId] - Unique identifier for the analyzed case
/// * [strengths] 
/// * [weaknesses] 
@BuiltValue()
abstract class AnalysisResponse implements Built<AnalysisResponse, AnalysisResponseBuilder> {
  /// Unique identifier for the analyzed case
  @BuiltValueField(wireName: r'caseId')
  String? get caseId;

  @BuiltValueField(wireName: r'strengths')
  BuiltList<Argument>? get strengths;

  @BuiltValueField(wireName: r'weaknesses')
  BuiltList<Argument>? get weaknesses;

  AnalysisResponse._();

  factory AnalysisResponse([void updates(AnalysisResponseBuilder b)]) = _$AnalysisResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnalysisResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnalysisResponse> get serializer => _$AnalysisResponseSerializer();
}

class _$AnalysisResponseSerializer implements PrimitiveSerializer<AnalysisResponse> {
  @override
  final Iterable<Type> types = const [AnalysisResponse, _$AnalysisResponse];

  @override
  final String wireName = r'AnalysisResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnalysisResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.caseId != null) {
      yield r'caseId';
      yield serializers.serialize(
        object.caseId,
        specifiedType: const FullType(String),
      );
    }
    if (object.strengths != null) {
      yield r'strengths';
      yield serializers.serialize(
        object.strengths,
        specifiedType: const FullType(BuiltList, [FullType(Argument)]),
      );
    }
    if (object.weaknesses != null) {
      yield r'weaknesses';
      yield serializers.serialize(
        object.weaknesses,
        specifiedType: const FullType(BuiltList, [FullType(Argument)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnalysisResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnalysisResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'caseId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.caseId = valueDes;
          break;
        case r'strengths':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Argument)]),
          ) as BuiltList<Argument>;
          result.strengths.replace(valueDes);
          break;
        case r'weaknesses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Argument)]),
          ) as BuiltList<Argument>;
          result.weaknesses.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnalysisResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnalysisResponseBuilder();
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

