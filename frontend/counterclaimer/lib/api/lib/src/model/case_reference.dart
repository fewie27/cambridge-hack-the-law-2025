//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:my_flutter_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'case_reference.g.dart';

/// CaseReference
///
/// Properties:
/// * [caseIdentifier] - Unique identifier for the case
/// * [title] - Title of the case
/// * [date] - Date of the case
/// * [matchingDegree] - Matching degree score
/// * [fileReference] - Reference to the case file
@BuiltValue()
abstract class CaseReference implements Built<CaseReference, CaseReferenceBuilder> {
  /// Unique identifier for the case
  @BuiltValueField(wireName: r'caseIdentifier')
  String? get caseIdentifier;

  /// Title of the case
  @BuiltValueField(wireName: r'title')
  String? get title;

  /// Date of the case
  @BuiltValueField(wireName: r'Date')
  Date? get date;

  /// Matching degree score
  @BuiltValueField(wireName: r'matchingDegree')
  double? get matchingDegree;

  /// Reference to the case file
  @BuiltValueField(wireName: r'fileReference')
  String? get fileReference;

  CaseReference._();

  factory CaseReference([void updates(CaseReferenceBuilder b)]) = _$CaseReference;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CaseReferenceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CaseReference> get serializer => _$CaseReferenceSerializer();
}

class _$CaseReferenceSerializer implements PrimitiveSerializer<CaseReference> {
  @override
  final Iterable<Type> types = const [CaseReference, _$CaseReference];

  @override
  final String wireName = r'CaseReference';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CaseReference object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.caseIdentifier != null) {
      yield r'caseIdentifier';
      yield serializers.serialize(
        object.caseIdentifier,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.date != null) {
      yield r'Date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.matchingDegree != null) {
      yield r'matchingDegree';
      yield serializers.serialize(
        object.matchingDegree,
        specifiedType: const FullType(double),
      );
    }
    if (object.fileReference != null) {
      yield r'fileReference';
      yield serializers.serialize(
        object.fileReference,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CaseReference object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CaseReferenceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'caseIdentifier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.caseIdentifier = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'Date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.date = valueDes;
          break;
        case r'matchingDegree':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.matchingDegree = valueDes;
          break;
        case r'fileReference':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fileReference = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CaseReference deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CaseReferenceBuilder();
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

