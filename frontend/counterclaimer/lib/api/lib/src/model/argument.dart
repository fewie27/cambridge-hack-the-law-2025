//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:my_flutter_api_client/src/model/case_reference.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'argument.g.dart';

/// Argument
///
/// Properties:
/// * [argument] - The legal argument
/// * [caseReferences] 
@BuiltValue()
abstract class Argument implements Built<Argument, ArgumentBuilder> {
  /// The legal argument
  @BuiltValueField(wireName: r'argument')
  String? get argument;

  @BuiltValueField(wireName: r'case_references')
  BuiltList<CaseReference>? get caseReferences;

  Argument._();

  factory Argument([void updates(ArgumentBuilder b)]) = _$Argument;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ArgumentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Argument> get serializer => _$ArgumentSerializer();
}

class _$ArgumentSerializer implements PrimitiveSerializer<Argument> {
  @override
  final Iterable<Type> types = const [Argument, _$Argument];

  @override
  final String wireName = r'Argument';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Argument object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.argument != null) {
      yield r'argument';
      yield serializers.serialize(
        object.argument,
        specifiedType: const FullType(String),
      );
    }
    if (object.caseReferences != null) {
      yield r'case_references';
      yield serializers.serialize(
        object.caseReferences,
        specifiedType: const FullType(BuiltList, [FullType(CaseReference)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Argument object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ArgumentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'argument':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.argument = valueDes;
          break;
        case r'case_references':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CaseReference)]),
          ) as BuiltList<CaseReference>;
          result.caseReferences.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Argument deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ArgumentBuilder();
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

