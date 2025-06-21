//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:my_flutter_api_client/src/date_serializer.dart';
import 'package:my_flutter_api_client/src/model/date.dart';

import 'package:my_flutter_api_client/src/model/add_case_request.dart';
import 'package:my_flutter_api_client/src/model/analysis_response.dart';
import 'package:my_flutter_api_client/src/model/argument.dart';
import 'package:my_flutter_api_client/src/model/case_reference.dart';
import 'package:my_flutter_api_client/src/model/error.dart';
import 'package:my_flutter_api_client/src/model/get_health200_response.dart';
import 'package:my_flutter_api_client/src/model/get_health500_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  AddCaseRequest,
  AnalysisResponse,
  Argument,
  CaseReference,
  Error,
  GetHealth200Response,
  GetHealth500Response,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
