// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalProfileCollection on Isar {
  IsarCollection<LocalProfile> get localProfiles => this.collection();
}

const LocalProfileSchema = CollectionSchema(
  name: r'LocalProfile',
  id: -3481655517967548928,
  properties: {
    r'avatarUrl': PropertySchema(
      id: 0,
      name: r'avatarUrl',
      type: IsarType.string,
    ),
    r'cigarettesPerDay': PropertySchema(
      id: 1,
      name: r'cigarettesPerDay',
      type: IsarType.long,
    ),
    r'currencyCode': PropertySchema(
      id: 2,
      name: r'currencyCode',
      type: IsarType.string,
    ),
    r'currencySymbol': PropertySchema(
      id: 3,
      name: r'currencySymbol',
      type: IsarType.string,
    ),
    r'displayName': PropertySchema(
      id: 4,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'packPrice': PropertySchema(
      id: 5,
      name: r'packPrice',
      type: IsarType.double,
    ),
    r'packSize': PropertySchema(id: 6, name: r'packSize', type: IsarType.long),
    r'quitDate': PropertySchema(
      id: 7,
      name: r'quitDate',
      type: IsarType.dateTime,
    ),
    r'quitReason': PropertySchema(
      id: 8,
      name: r'quitReason',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 9, name: r'synced', type: IsarType.bool),
    r'triggers': PropertySchema(
      id: 10,
      name: r'triggers',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'userId': PropertySchema(id: 12, name: r'userId', type: IsarType.string),
  },

  estimateSize: _localProfileEstimateSize,
  serialize: _localProfileSerialize,
  deserialize: _localProfileDeserialize,
  deserializeProp: _localProfileDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _localProfileGetId,
  getLinks: _localProfileGetLinks,
  attach: _localProfileAttach,
  version: '3.3.2',
);

int _localProfileEstimateSize(
  LocalProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.avatarUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.currencyCode.length * 3;
  bytesCount += 3 + object.currencySymbol.length * 3;
  bytesCount += 3 + object.displayName.length * 3;
  {
    final value = object.quitReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.triggers.length * 3;
  {
    for (var i = 0; i < object.triggers.length; i++) {
      final value = object.triggers[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _localProfileSerialize(
  LocalProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.avatarUrl);
  writer.writeLong(offsets[1], object.cigarettesPerDay);
  writer.writeString(offsets[2], object.currencyCode);
  writer.writeString(offsets[3], object.currencySymbol);
  writer.writeString(offsets[4], object.displayName);
  writer.writeDouble(offsets[5], object.packPrice);
  writer.writeLong(offsets[6], object.packSize);
  writer.writeDateTime(offsets[7], object.quitDate);
  writer.writeString(offsets[8], object.quitReason);
  writer.writeBool(offsets[9], object.synced);
  writer.writeStringList(offsets[10], object.triggers);
  writer.writeDateTime(offsets[11], object.updatedAt);
  writer.writeString(offsets[12], object.userId);
}

LocalProfile _localProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalProfile();
  object.avatarUrl = reader.readStringOrNull(offsets[0]);
  object.cigarettesPerDay = reader.readLong(offsets[1]);
  object.currencyCode = reader.readString(offsets[2]);
  object.currencySymbol = reader.readString(offsets[3]);
  object.displayName = reader.readString(offsets[4]);
  object.id = id;
  object.packPrice = reader.readDouble(offsets[5]);
  object.packSize = reader.readLong(offsets[6]);
  object.quitDate = reader.readDateTime(offsets[7]);
  object.quitReason = reader.readStringOrNull(offsets[8]);
  object.synced = reader.readBool(offsets[9]);
  object.triggers = reader.readStringList(offsets[10]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[11]);
  object.userId = reader.readString(offsets[12]);
  return object;
}

P _localProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localProfileGetId(LocalProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localProfileGetLinks(LocalProfile object) {
  return [];
}

void _localProfileAttach(
  IsarCollection<dynamic> col,
  Id id,
  LocalProfile object,
) {
  object.id = id;
}

extension LocalProfileByIndex on IsarCollection<LocalProfile> {
  Future<LocalProfile?> getByUserId(String userId) {
    return getByIndex(r'userId', [userId]);
  }

  LocalProfile? getByUserIdSync(String userId) {
    return getByIndexSync(r'userId', [userId]);
  }

  Future<bool> deleteByUserId(String userId) {
    return deleteByIndex(r'userId', [userId]);
  }

  bool deleteByUserIdSync(String userId) {
    return deleteByIndexSync(r'userId', [userId]);
  }

  Future<List<LocalProfile?>> getAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'userId', values);
  }

  List<LocalProfile?> getAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'userId', values);
  }

  Future<int> deleteAllByUserId(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'userId', values);
  }

  int deleteAllByUserIdSync(List<String> userIdValues) {
    final values = userIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'userId', values);
  }

  Future<Id> putByUserId(LocalProfile object) {
    return putByIndex(r'userId', object);
  }

  Id putByUserIdSync(LocalProfile object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserId(List<LocalProfile> objects) {
    return putAllByIndex(r'userId', objects);
  }

  List<Id> putAllByUserIdSync(
    List<LocalProfile> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'userId', objects, saveLinks: saveLinks);
  }
}

extension LocalProfileQueryWhereSort
    on QueryBuilder<LocalProfile, LocalProfile, QWhere> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalProfileQueryWhere
    on QueryBuilder<LocalProfile, LocalProfile, QWhereClause> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> userIdEqualTo(
    String userId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'userId', value: [userId]),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterWhereClause> userIdNotEqualTo(
    String userId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LocalProfileQueryFilter
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'avatarUrl'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'avatarUrl'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'avatarUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'avatarUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'avatarUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'avatarUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'avatarUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'avatarUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'avatarUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'avatarUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'avatarUrl', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  avatarUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'avatarUrl', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  cigarettesPerDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cigarettesPerDay', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  cigarettesPerDayGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cigarettesPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  cigarettesPerDayLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cigarettesPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  cigarettesPerDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cigarettesPerDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencyCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencyCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencyCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencySymbol',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencySymbol',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencySymbol', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  currencySymbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencySymbol', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displayName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'displayName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packPriceEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'packPrice',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packPrice',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packPrice',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packPrice',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'packSize', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packSizeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packSizeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  packSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quitDate', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quitDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quitDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quitDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quitReason'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quitReason'),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quitReason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'quitReason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quitReason', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  quitReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'quitReason', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'triggers',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'triggers',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'triggers', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'triggers', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', length, true, length, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, true, 0, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, false, 999999, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, true, length, include);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', length, include, 999999, true);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  triggersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggers',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition> userIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }
}

extension LocalProfileQueryObject
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {}

extension LocalProfileQueryLinks
    on QueryBuilder<LocalProfile, LocalProfile, QFilterCondition> {}

extension LocalProfileQuerySortBy
    on QueryBuilder<LocalProfile, LocalProfile, QSortBy> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCigarettesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCigarettesPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCurrencySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByCurrencySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByPackPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByPackSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByPackSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByQuitReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  sortByQuitReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalProfileQuerySortThenBy
    on QueryBuilder<LocalProfile, LocalProfile, QSortThenBy> {
  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatarUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCigarettesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCigarettesPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCurrencySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByCurrencySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByPackPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByPackSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByPackSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByQuitReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy>
  thenByQuitReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension LocalProfileQueryWhereDistinct
    on QueryBuilder<LocalProfile, LocalProfile, QDistinct> {
  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByAvatarUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatarUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct>
  distinctByCigarettesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cigarettesPerDay');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByCurrencyCode({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByCurrencySymbol({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currencySymbol',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByDisplayName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packPrice');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByPackSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packSize');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quitDate');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByQuitReason({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quitReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByTriggers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggers');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<LocalProfile, LocalProfile, QDistinct> distinctByUserId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension LocalProfileQueryProperty
    on QueryBuilder<LocalProfile, LocalProfile, QQueryProperty> {
  QueryBuilder<LocalProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalProfile, String?, QQueryOperations> avatarUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatarUrl');
    });
  }

  QueryBuilder<LocalProfile, int, QQueryOperations> cigarettesPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cigarettesPerDay');
    });
  }

  QueryBuilder<LocalProfile, String, QQueryOperations> currencyCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyCode');
    });
  }

  QueryBuilder<LocalProfile, String, QQueryOperations>
  currencySymbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencySymbol');
    });
  }

  QueryBuilder<LocalProfile, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<LocalProfile, double, QQueryOperations> packPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packPrice');
    });
  }

  QueryBuilder<LocalProfile, int, QQueryOperations> packSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packSize');
    });
  }

  QueryBuilder<LocalProfile, DateTime, QQueryOperations> quitDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quitDate');
    });
  }

  QueryBuilder<LocalProfile, String?, QQueryOperations> quitReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quitReason');
    });
  }

  QueryBuilder<LocalProfile, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<LocalProfile, List<String>, QQueryOperations>
  triggersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggers');
    });
  }

  QueryBuilder<LocalProfile, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<LocalProfile, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOnboardingDraftCollection on Isar {
  IsarCollection<OnboardingDraft> get onboardingDrafts => this.collection();
}

const OnboardingDraftSchema = CollectionSchema(
  name: r'OnboardingDraft',
  id: -2331744847438040940,
  properties: {
    r'cigarettesPerDay': PropertySchema(
      id: 0,
      name: r'cigarettesPerDay',
      type: IsarType.long,
    ),
    r'completed': PropertySchema(
      id: 1,
      name: r'completed',
      type: IsarType.bool,
    ),
    r'currencyCode': PropertySchema(
      id: 2,
      name: r'currencyCode',
      type: IsarType.string,
    ),
    r'currencySymbol': PropertySchema(
      id: 3,
      name: r'currencySymbol',
      type: IsarType.string,
    ),
    r'currentStep': PropertySchema(
      id: 4,
      name: r'currentStep',
      type: IsarType.long,
    ),
    r'packPrice': PropertySchema(
      id: 5,
      name: r'packPrice',
      type: IsarType.double,
    ),
    r'packSize': PropertySchema(id: 6, name: r'packSize', type: IsarType.long),
    r'quitDate': PropertySchema(
      id: 7,
      name: r'quitDate',
      type: IsarType.dateTime,
    ),
    r'quitReason': PropertySchema(
      id: 8,
      name: r'quitReason',
      type: IsarType.string,
    ),
    r'triggers': PropertySchema(
      id: 9,
      name: r'triggers',
      type: IsarType.stringList,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _onboardingDraftEstimateSize,
  serialize: _onboardingDraftSerialize,
  deserialize: _onboardingDraftDeserialize,
  deserializeProp: _onboardingDraftDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _onboardingDraftGetId,
  getLinks: _onboardingDraftGetLinks,
  attach: _onboardingDraftAttach,
  version: '3.3.2',
);

int _onboardingDraftEstimateSize(
  OnboardingDraft object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currencyCode.length * 3;
  bytesCount += 3 + object.currencySymbol.length * 3;
  {
    final value = object.quitReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.triggers.length * 3;
  {
    for (var i = 0; i < object.triggers.length; i++) {
      final value = object.triggers[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _onboardingDraftSerialize(
  OnboardingDraft object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.cigarettesPerDay);
  writer.writeBool(offsets[1], object.completed);
  writer.writeString(offsets[2], object.currencyCode);
  writer.writeString(offsets[3], object.currencySymbol);
  writer.writeLong(offsets[4], object.currentStep);
  writer.writeDouble(offsets[5], object.packPrice);
  writer.writeLong(offsets[6], object.packSize);
  writer.writeDateTime(offsets[7], object.quitDate);
  writer.writeString(offsets[8], object.quitReason);
  writer.writeStringList(offsets[9], object.triggers);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

OnboardingDraft _onboardingDraftDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OnboardingDraft();
  object.cigarettesPerDay = reader.readLongOrNull(offsets[0]);
  object.completed = reader.readBool(offsets[1]);
  object.currencyCode = reader.readString(offsets[2]);
  object.currencySymbol = reader.readString(offsets[3]);
  object.currentStep = reader.readLong(offsets[4]);
  object.id = id;
  object.packPrice = reader.readDoubleOrNull(offsets[5]);
  object.packSize = reader.readLongOrNull(offsets[6]);
  object.quitDate = reader.readDateTimeOrNull(offsets[7]);
  object.quitReason = reader.readStringOrNull(offsets[8]);
  object.triggers = reader.readStringList(offsets[9]) ?? [];
  object.updatedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _onboardingDraftDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _onboardingDraftGetId(OnboardingDraft object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _onboardingDraftGetLinks(OnboardingDraft object) {
  return [];
}

void _onboardingDraftAttach(
  IsarCollection<dynamic> col,
  Id id,
  OnboardingDraft object,
) {
  object.id = id;
}

extension OnboardingDraftQueryWhereSort
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QWhere> {
  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OnboardingDraftQueryWhere
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QWhereClause> {
  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OnboardingDraftQueryFilter
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QFilterCondition> {
  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  cigarettesPerDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cigarettesPerDay'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  cigarettesPerDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cigarettesPerDay'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  cigarettesPerDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cigarettesPerDay', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  cigarettesPerDayGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cigarettesPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  cigarettesPerDayLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cigarettesPerDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  cigarettesPerDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cigarettesPerDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  completedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completed', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencyCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencyCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencyCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencyCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencyCode', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currencySymbol',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currencySymbol',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currencySymbol',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currencySymbol', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currencySymbolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currencySymbol', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currentStepEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentStep', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currentStepGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentStep',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currentStepLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentStep',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  currentStepBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentStep',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packPriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'packPrice'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packPriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'packPrice'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packPriceEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'packPrice',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packPriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packPrice',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packPriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packPrice',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packPriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packPrice',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'packSize'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'packSize'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packSizeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'packSize', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packSizeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'packSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packSizeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'packSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  packSizeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'packSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quitDate'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quitDate'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quitDate', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quitDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quitDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quitDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quitReason'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quitReason'),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quitReason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'quitReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'quitReason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quitReason', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  quitReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'quitReason', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'triggers',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'triggers',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'triggers', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'triggers', value: ''),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', length, true, length, true);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, true, 0, true);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, false, 999999, true);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, true, length, include);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', length, include, 999999, true);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  triggersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggers',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OnboardingDraftQueryObject
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QFilterCondition> {}

extension OnboardingDraftQueryLinks
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QFilterCondition> {}

extension OnboardingDraftQuerySortBy
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QSortBy> {
  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCigarettesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCigarettesPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCurrencySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCurrencySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCurrentStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByCurrentStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByPackPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByPackSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByPackSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByQuitReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByQuitReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension OnboardingDraftQuerySortThenBy
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QSortThenBy> {
  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCigarettesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCigarettesPerDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesPerDay', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completed', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCurrencySymbol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCurrencySymbolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencySymbol', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCurrentStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByCurrentStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByPackPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packPrice', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByPackSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByPackSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packSize', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByQuitDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitDate', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByQuitReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByQuitReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quitReason', Sort.desc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension OnboardingDraftQueryWhereDistinct
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct> {
  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByCigarettesPerDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cigarettesPerDay');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completed');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByCurrencyCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByCurrencySymbol({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currencySymbol',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByCurrentStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStep');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByPackPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packPrice');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByPackSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packSize');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByQuitDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quitDate');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByQuitReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quitReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByTriggers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggers');
    });
  }

  QueryBuilder<OnboardingDraft, OnboardingDraft, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension OnboardingDraftQueryProperty
    on QueryBuilder<OnboardingDraft, OnboardingDraft, QQueryProperty> {
  QueryBuilder<OnboardingDraft, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OnboardingDraft, int?, QQueryOperations>
  cigarettesPerDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cigarettesPerDay');
    });
  }

  QueryBuilder<OnboardingDraft, bool, QQueryOperations> completedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completed');
    });
  }

  QueryBuilder<OnboardingDraft, String, QQueryOperations>
  currencyCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyCode');
    });
  }

  QueryBuilder<OnboardingDraft, String, QQueryOperations>
  currencySymbolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencySymbol');
    });
  }

  QueryBuilder<OnboardingDraft, int, QQueryOperations> currentStepProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStep');
    });
  }

  QueryBuilder<OnboardingDraft, double?, QQueryOperations> packPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packPrice');
    });
  }

  QueryBuilder<OnboardingDraft, int?, QQueryOperations> packSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packSize');
    });
  }

  QueryBuilder<OnboardingDraft, DateTime?, QQueryOperations>
  quitDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quitDate');
    });
  }

  QueryBuilder<OnboardingDraft, String?, QQueryOperations>
  quitReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quitReason');
    });
  }

  QueryBuilder<OnboardingDraft, List<String>, QQueryOperations>
  triggersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggers');
    });
  }

  QueryBuilder<OnboardingDraft, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCravingRescueSessionCollection on Isar {
  IsarCollection<CravingRescueSession> get cravingRescueSessions =>
      this.collection();
}

const CravingRescueSessionSchema = CollectionSchema(
  name: r'CravingRescueSession',
  id: 8027835023354374808,
  properties: {
    r'completedAt': PropertySchema(
      id: 0,
      name: r'completedAt',
      type: IsarType.dateTime,
    ),
    r'intensity': PropertySchema(
      id: 1,
      name: r'intensity',
      type: IsarType.long,
    ),
    r'outcome': PropertySchema(id: 2, name: r'outcome', type: IsarType.string),
    r'sessionId': PropertySchema(
      id: 3,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'startedAt': PropertySchema(
      id: 4,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'synced': PropertySchema(id: 5, name: r'synced', type: IsarType.bool),
    r'triggers': PropertySchema(
      id: 6,
      name: r'triggers',
      type: IsarType.stringList,
    ),
  },

  estimateSize: _cravingRescueSessionEstimateSize,
  serialize: _cravingRescueSessionSerialize,
  deserialize: _cravingRescueSessionDeserialize,
  deserializeProp: _cravingRescueSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _cravingRescueSessionGetId,
  getLinks: _cravingRescueSessionGetLinks,
  attach: _cravingRescueSessionAttach,
  version: '3.3.2',
);

int _cravingRescueSessionEstimateSize(
  CravingRescueSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.outcome.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.triggers.length * 3;
  {
    for (var i = 0; i < object.triggers.length; i++) {
      final value = object.triggers[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _cravingRescueSessionSerialize(
  CravingRescueSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.completedAt);
  writer.writeLong(offsets[1], object.intensity);
  writer.writeString(offsets[2], object.outcome);
  writer.writeString(offsets[3], object.sessionId);
  writer.writeDateTime(offsets[4], object.startedAt);
  writer.writeBool(offsets[5], object.synced);
  writer.writeStringList(offsets[6], object.triggers);
}

CravingRescueSession _cravingRescueSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CravingRescueSession();
  object.completedAt = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.intensity = reader.readLong(offsets[1]);
  object.outcome = reader.readString(offsets[2]);
  object.sessionId = reader.readString(offsets[3]);
  object.startedAt = reader.readDateTime(offsets[4]);
  object.synced = reader.readBool(offsets[5]);
  object.triggers = reader.readStringList(offsets[6]) ?? [];
  return object;
}

P _cravingRescueSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cravingRescueSessionGetId(CravingRescueSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cravingRescueSessionGetLinks(
  CravingRescueSession object,
) {
  return [];
}

void _cravingRescueSessionAttach(
  IsarCollection<dynamic> col,
  Id id,
  CravingRescueSession object,
) {
  object.id = id;
}

extension CravingRescueSessionByIndex on IsarCollection<CravingRescueSession> {
  Future<CravingRescueSession?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  CravingRescueSession? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<CravingRescueSession?>> getAllBySessionId(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<CravingRescueSession?> getAllBySessionIdSync(
    List<String> sessionIdValues,
  ) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(CravingRescueSession object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(CravingRescueSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<CravingRescueSession> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(
    List<CravingRescueSession> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension CravingRescueSessionQueryWhereSort
    on QueryBuilder<CravingRescueSession, CravingRescueSession, QWhere> {
  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CravingRescueSessionQueryWhere
    on QueryBuilder<CravingRescueSession, CravingRescueSession, QWhereClause> {
  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'sessionId', value: [sessionId]),
      );
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterWhereClause>
  sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [sessionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'sessionId',
                lower: [],
                upper: [sessionId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CravingRescueSessionQueryFilter
    on
        QueryBuilder<
          CravingRescueSession,
          CravingRescueSession,
          QFilterCondition
        > {
  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  completedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completedAt'),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  completedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedAt', value: value),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  completedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  completedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  completedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  intensityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'intensity', value: value),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  intensityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intensity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  intensityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intensity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  intensityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intensity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outcome',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'outcome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outcome', value: ''),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  outcomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'outcome', value: ''),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startedAt', value: value),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  startedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  startedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'triggers',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'triggers',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'triggers',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'triggers', value: ''),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'triggers', value: ''),
      );
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', length, true, length, true);
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, true, 0, true);
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', 0, true, length, include);
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'triggers', length, include, 999999, true);
    });
  }

  QueryBuilder<
    CravingRescueSession,
    CravingRescueSession,
    QAfterFilterCondition
  >
  triggersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'triggers',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension CravingRescueSessionQueryObject
    on
        QueryBuilder<
          CravingRescueSession,
          CravingRescueSession,
          QFilterCondition
        > {}

extension CravingRescueSessionQueryLinks
    on
        QueryBuilder<
          CravingRescueSession,
          CravingRescueSession,
          QFilterCondition
        > {}

extension CravingRescueSessionQuerySortBy
    on QueryBuilder<CravingRescueSession, CravingRescueSession, QSortBy> {
  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intensity', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intensity', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension CravingRescueSessionQuerySortThenBy
    on QueryBuilder<CravingRescueSession, CravingRescueSession, QSortThenBy> {
  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedAt', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intensity', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByIntensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intensity', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension CravingRescueSessionQueryWhereDistinct
    on QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct> {
  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedAt');
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctByIntensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intensity');
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctByOutcome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<CravingRescueSession, CravingRescueSession, QDistinct>
  distinctByTriggers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggers');
    });
  }
}

extension CravingRescueSessionQueryProperty
    on
        QueryBuilder<
          CravingRescueSession,
          CravingRescueSession,
          QQueryProperty
        > {
  QueryBuilder<CravingRescueSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CravingRescueSession, DateTime?, QQueryOperations>
  completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedAt');
    });
  }

  QueryBuilder<CravingRescueSession, int, QQueryOperations>
  intensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intensity');
    });
  }

  QueryBuilder<CravingRescueSession, String, QQueryOperations>
  outcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcome');
    });
  }

  QueryBuilder<CravingRescueSession, String, QQueryOperations>
  sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<CravingRescueSession, DateTime, QQueryOperations>
  startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<CravingRescueSession, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<CravingRescueSession, List<String>, QQueryOperations>
  triggersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggers');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSmokingLogCollection on Isar {
  IsarCollection<SmokingLog> get smokingLogs => this.collection();
}

const SmokingLogSchema = CollectionSchema(
  name: r'SmokingLog',
  id: 5153543125690535158,
  properties: {
    r'count': PropertySchema(id: 0, name: r'count', type: IsarType.long),
    r'logId': PropertySchema(id: 1, name: r'logId', type: IsarType.string),
    r'note': PropertySchema(id: 2, name: r'note', type: IsarType.string),
    r'smokedAt': PropertySchema(
      id: 3,
      name: r'smokedAt',
      type: IsarType.dateTime,
    ),
    r'synced': PropertySchema(id: 4, name: r'synced', type: IsarType.bool),
    r'trigger': PropertySchema(id: 5, name: r'trigger', type: IsarType.string),
  },

  estimateSize: _smokingLogEstimateSize,
  serialize: _smokingLogSerialize,
  deserialize: _smokingLogDeserialize,
  deserializeProp: _smokingLogDeserializeProp,
  idName: r'id',
  indexes: {
    r'logId': IndexSchema(
      id: 3089637606214822530,
      name: r'logId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'logId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _smokingLogGetId,
  getLinks: _smokingLogGetLinks,
  attach: _smokingLogAttach,
  version: '3.3.2',
);

int _smokingLogEstimateSize(
  SmokingLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.logId.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.trigger.length * 3;
  return bytesCount;
}

void _smokingLogSerialize(
  SmokingLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.count);
  writer.writeString(offsets[1], object.logId);
  writer.writeString(offsets[2], object.note);
  writer.writeDateTime(offsets[3], object.smokedAt);
  writer.writeBool(offsets[4], object.synced);
  writer.writeString(offsets[5], object.trigger);
}

SmokingLog _smokingLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SmokingLog();
  object.count = reader.readLong(offsets[0]);
  object.id = id;
  object.logId = reader.readString(offsets[1]);
  object.note = reader.readStringOrNull(offsets[2]);
  object.smokedAt = reader.readDateTime(offsets[3]);
  object.synced = reader.readBool(offsets[4]);
  object.trigger = reader.readString(offsets[5]);
  return object;
}

P _smokingLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _smokingLogGetId(SmokingLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _smokingLogGetLinks(SmokingLog object) {
  return [];
}

void _smokingLogAttach(IsarCollection<dynamic> col, Id id, SmokingLog object) {
  object.id = id;
}

extension SmokingLogByIndex on IsarCollection<SmokingLog> {
  Future<SmokingLog?> getByLogId(String logId) {
    return getByIndex(r'logId', [logId]);
  }

  SmokingLog? getByLogIdSync(String logId) {
    return getByIndexSync(r'logId', [logId]);
  }

  Future<bool> deleteByLogId(String logId) {
    return deleteByIndex(r'logId', [logId]);
  }

  bool deleteByLogIdSync(String logId) {
    return deleteByIndexSync(r'logId', [logId]);
  }

  Future<List<SmokingLog?>> getAllByLogId(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'logId', values);
  }

  List<SmokingLog?> getAllByLogIdSync(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'logId', values);
  }

  Future<int> deleteAllByLogId(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'logId', values);
  }

  int deleteAllByLogIdSync(List<String> logIdValues) {
    final values = logIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'logId', values);
  }

  Future<Id> putByLogId(SmokingLog object) {
    return putByIndex(r'logId', object);
  }

  Id putByLogIdSync(SmokingLog object, {bool saveLinks = true}) {
    return putByIndexSync(r'logId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLogId(List<SmokingLog> objects) {
    return putAllByIndex(r'logId', objects);
  }

  List<Id> putAllByLogIdSync(
    List<SmokingLog> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'logId', objects, saveLinks: saveLinks);
  }
}

extension SmokingLogQueryWhereSort
    on QueryBuilder<SmokingLog, SmokingLog, QWhere> {
  QueryBuilder<SmokingLog, SmokingLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SmokingLogQueryWhere
    on QueryBuilder<SmokingLog, SmokingLog, QWhereClause> {
  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> logIdEqualTo(
    String logId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'logId', value: [logId]),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterWhereClause> logIdNotEqualTo(
    String logId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [],
                upper: [logId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [logId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [logId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'logId',
                lower: [],
                upper: [logId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SmokingLogQueryFilter
    on QueryBuilder<SmokingLog, SmokingLog, QFilterCondition> {
  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> countEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'count', value: value),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> countGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'count',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> countLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'count',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> countBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'count',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> logIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logId', value: ''),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition>
  logIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logId', value: ''),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> smokedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'smokedAt', value: value),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition>
  smokedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'smokedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> smokedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'smokedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> smokedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'smokedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition>
  triggerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trigger',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'trigger',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'trigger',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition> triggerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trigger', value: ''),
      );
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterFilterCondition>
  triggerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'trigger', value: ''),
      );
    });
  }
}

extension SmokingLogQueryObject
    on QueryBuilder<SmokingLog, SmokingLog, QFilterCondition> {}

extension SmokingLogQueryLinks
    on QueryBuilder<SmokingLog, SmokingLog, QFilterCondition> {}

extension SmokingLogQuerySortBy
    on QueryBuilder<SmokingLog, SmokingLog, QSortBy> {
  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortBySmokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortBySmokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokedAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> sortByTriggerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.desc);
    });
  }
}

extension SmokingLogQuerySortThenBy
    on QueryBuilder<SmokingLog, SmokingLog, QSortThenBy> {
  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByLogId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByLogIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logId', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenBySmokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokedAt', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenBySmokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokedAt', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByTrigger() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.asc);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QAfterSortBy> thenByTriggerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trigger', Sort.desc);
    });
  }
}

extension SmokingLogQueryWhereDistinct
    on QueryBuilder<SmokingLog, SmokingLog, QDistinct> {
  QueryBuilder<SmokingLog, SmokingLog, QDistinct> distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QDistinct> distinctByLogId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QDistinct> distinctBySmokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smokedAt');
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<SmokingLog, SmokingLog, QDistinct> distinctByTrigger({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trigger', caseSensitive: caseSensitive);
    });
  }
}

extension SmokingLogQueryProperty
    on QueryBuilder<SmokingLog, SmokingLog, QQueryProperty> {
  QueryBuilder<SmokingLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SmokingLog, int, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<SmokingLog, String, QQueryOperations> logIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logId');
    });
  }

  QueryBuilder<SmokingLog, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<SmokingLog, DateTime, QQueryOperations> smokedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smokedAt');
    });
  }

  QueryBuilder<SmokingLog, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<SmokingLog, String, QQueryOperations> triggerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trigger');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyCheckInCollection on Isar {
  IsarCollection<DailyCheckIn> get dailyCheckIns => this.collection();
}

const DailyCheckInSchema = CollectionSchema(
  name: r'DailyCheckIn',
  id: -527065190331744543,
  properties: {
    r'checkInId': PropertySchema(
      id: 0,
      name: r'checkInId',
      type: IsarType.string,
    ),
    r'cigarettesSmoked': PropertySchema(
      id: 1,
      name: r'cigarettesSmoked',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'localDate': PropertySchema(
      id: 3,
      name: r'localDate',
      type: IsarType.string,
    ),
    r'mood': PropertySchema(id: 4, name: r'mood', type: IsarType.long),
    r'note': PropertySchema(id: 5, name: r'note', type: IsarType.string),
    r'smokeFreeToday': PropertySchema(
      id: 6,
      name: r'smokeFreeToday',
      type: IsarType.bool,
    ),
    r'synced': PropertySchema(id: 7, name: r'synced', type: IsarType.bool),
  },

  estimateSize: _dailyCheckInEstimateSize,
  serialize: _dailyCheckInSerialize,
  deserialize: _dailyCheckInDeserialize,
  deserializeProp: _dailyCheckInDeserializeProp,
  idName: r'id',
  indexes: {
    r'checkInId': IndexSchema(
      id: 1841632595250945841,
      name: r'checkInId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'checkInId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'localDate': IndexSchema(
      id: 2744483300516138583,
      name: r'localDate',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'localDate',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _dailyCheckInGetId,
  getLinks: _dailyCheckInGetLinks,
  attach: _dailyCheckInAttach,
  version: '3.3.2',
);

int _dailyCheckInEstimateSize(
  DailyCheckIn object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.checkInId.length * 3;
  bytesCount += 3 + object.localDate.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _dailyCheckInSerialize(
  DailyCheckIn object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.checkInId);
  writer.writeLong(offsets[1], object.cigarettesSmoked);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.localDate);
  writer.writeLong(offsets[4], object.mood);
  writer.writeString(offsets[5], object.note);
  writer.writeBool(offsets[6], object.smokeFreeToday);
  writer.writeBool(offsets[7], object.synced);
}

DailyCheckIn _dailyCheckInDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyCheckIn();
  object.checkInId = reader.readString(offsets[0]);
  object.cigarettesSmoked = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.localDate = reader.readString(offsets[3]);
  object.mood = reader.readLong(offsets[4]);
  object.note = reader.readStringOrNull(offsets[5]);
  object.smokeFreeToday = reader.readBool(offsets[6]);
  object.synced = reader.readBool(offsets[7]);
  return object;
}

P _dailyCheckInDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyCheckInGetId(DailyCheckIn object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyCheckInGetLinks(DailyCheckIn object) {
  return [];
}

void _dailyCheckInAttach(
  IsarCollection<dynamic> col,
  Id id,
  DailyCheckIn object,
) {
  object.id = id;
}

extension DailyCheckInByIndex on IsarCollection<DailyCheckIn> {
  Future<DailyCheckIn?> getByCheckInId(String checkInId) {
    return getByIndex(r'checkInId', [checkInId]);
  }

  DailyCheckIn? getByCheckInIdSync(String checkInId) {
    return getByIndexSync(r'checkInId', [checkInId]);
  }

  Future<bool> deleteByCheckInId(String checkInId) {
    return deleteByIndex(r'checkInId', [checkInId]);
  }

  bool deleteByCheckInIdSync(String checkInId) {
    return deleteByIndexSync(r'checkInId', [checkInId]);
  }

  Future<List<DailyCheckIn?>> getAllByCheckInId(List<String> checkInIdValues) {
    final values = checkInIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'checkInId', values);
  }

  List<DailyCheckIn?> getAllByCheckInIdSync(List<String> checkInIdValues) {
    final values = checkInIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'checkInId', values);
  }

  Future<int> deleteAllByCheckInId(List<String> checkInIdValues) {
    final values = checkInIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'checkInId', values);
  }

  int deleteAllByCheckInIdSync(List<String> checkInIdValues) {
    final values = checkInIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'checkInId', values);
  }

  Future<Id> putByCheckInId(DailyCheckIn object) {
    return putByIndex(r'checkInId', object);
  }

  Id putByCheckInIdSync(DailyCheckIn object, {bool saveLinks = true}) {
    return putByIndexSync(r'checkInId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCheckInId(List<DailyCheckIn> objects) {
    return putAllByIndex(r'checkInId', objects);
  }

  List<Id> putAllByCheckInIdSync(
    List<DailyCheckIn> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'checkInId', objects, saveLinks: saveLinks);
  }

  Future<DailyCheckIn?> getByLocalDate(String localDate) {
    return getByIndex(r'localDate', [localDate]);
  }

  DailyCheckIn? getByLocalDateSync(String localDate) {
    return getByIndexSync(r'localDate', [localDate]);
  }

  Future<bool> deleteByLocalDate(String localDate) {
    return deleteByIndex(r'localDate', [localDate]);
  }

  bool deleteByLocalDateSync(String localDate) {
    return deleteByIndexSync(r'localDate', [localDate]);
  }

  Future<List<DailyCheckIn?>> getAllByLocalDate(List<String> localDateValues) {
    final values = localDateValues.map((e) => [e]).toList();
    return getAllByIndex(r'localDate', values);
  }

  List<DailyCheckIn?> getAllByLocalDateSync(List<String> localDateValues) {
    final values = localDateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'localDate', values);
  }

  Future<int> deleteAllByLocalDate(List<String> localDateValues) {
    final values = localDateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'localDate', values);
  }

  int deleteAllByLocalDateSync(List<String> localDateValues) {
    final values = localDateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'localDate', values);
  }

  Future<Id> putByLocalDate(DailyCheckIn object) {
    return putByIndex(r'localDate', object);
  }

  Id putByLocalDateSync(DailyCheckIn object, {bool saveLinks = true}) {
    return putByIndexSync(r'localDate', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLocalDate(List<DailyCheckIn> objects) {
    return putAllByIndex(r'localDate', objects);
  }

  List<Id> putAllByLocalDateSync(
    List<DailyCheckIn> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'localDate', objects, saveLinks: saveLinks);
  }
}

extension DailyCheckInQueryWhereSort
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QWhere> {
  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyCheckInQueryWhere
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QWhereClause> {
  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> checkInIdEqualTo(
    String checkInId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'checkInId', value: [checkInId]),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause>
  checkInIdNotEqualTo(String checkInId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkInId',
                lower: [],
                upper: [checkInId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkInId',
                lower: [checkInId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkInId',
                lower: [checkInId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'checkInId',
                lower: [],
                upper: [checkInId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause> localDateEqualTo(
    String localDate,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'localDate', value: [localDate]),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterWhereClause>
  localDateNotEqualTo(String localDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localDate',
                lower: [],
                upper: [localDate],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localDate',
                lower: [localDate],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localDate',
                lower: [localDate],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'localDate',
                lower: [],
                upper: [localDate],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension DailyCheckInQueryFilter
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QFilterCondition> {
  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'checkInId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'checkInId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'checkInId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'checkInId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'checkInId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'checkInId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'checkInId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'checkInId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'checkInId', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  checkInIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'checkInId', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  cigarettesSmokedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cigarettesSmoked', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  cigarettesSmokedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cigarettesSmoked',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  cigarettesSmokedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cigarettesSmoked',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  cigarettesSmokedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cigarettesSmoked',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localDate', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  localDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localDate', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> moodEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mood', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  moodGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mood',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> moodLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mood',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> moodBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mood',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'note'),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'note'),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> noteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition>
  smokeFreeTodayEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'smokeFreeToday', value: value),
      );
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }
}

extension DailyCheckInQueryObject
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QFilterCondition> {}

extension DailyCheckInQueryLinks
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QFilterCondition> {}

extension DailyCheckInQuerySortBy
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QSortBy> {
  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByCheckInId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInId', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByCheckInIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInId', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  sortByCigarettesSmoked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesSmoked', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  sortByCigarettesSmokedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesSmoked', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByLocalDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDate', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByLocalDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDate', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  sortBySmokeFreeToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokeFreeToday', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  sortBySmokeFreeTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokeFreeToday', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension DailyCheckInQuerySortThenBy
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QSortThenBy> {
  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByCheckInId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInId', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByCheckInIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checkInId', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  thenByCigarettesSmoked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesSmoked', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  thenByCigarettesSmokedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cigarettesSmoked', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByLocalDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDate', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByLocalDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDate', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  thenBySmokeFreeToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokeFreeToday', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy>
  thenBySmokeFreeTodayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'smokeFreeToday', Sort.desc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension DailyCheckInQueryWhereDistinct
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> {
  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> distinctByCheckInId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checkInId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct>
  distinctByCigarettesSmoked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cigarettesSmoked');
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> distinctByLocalDate({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> distinctByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mood');
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct>
  distinctBySmokeFreeToday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'smokeFreeToday');
    });
  }

  QueryBuilder<DailyCheckIn, DailyCheckIn, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }
}

extension DailyCheckInQueryProperty
    on QueryBuilder<DailyCheckIn, DailyCheckIn, QQueryProperty> {
  QueryBuilder<DailyCheckIn, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyCheckIn, String, QQueryOperations> checkInIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checkInId');
    });
  }

  QueryBuilder<DailyCheckIn, int, QQueryOperations> cigarettesSmokedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cigarettesSmoked');
    });
  }

  QueryBuilder<DailyCheckIn, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DailyCheckIn, String, QQueryOperations> localDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localDate');
    });
  }

  QueryBuilder<DailyCheckIn, int, QQueryOperations> moodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mood');
    });
  }

  QueryBuilder<DailyCheckIn, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<DailyCheckIn, bool, QQueryOperations> smokeFreeTodayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'smokeFreeToday');
    });
  }

  QueryBuilder<DailyCheckIn, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAchievementStateCollection on Isar {
  IsarCollection<AchievementState> get achievementStates => this.collection();
}

const AchievementStateSchema = CollectionSchema(
  name: r'AchievementState',
  id: -5431218162034915530,
  properties: {
    r'achievementKey': PropertySchema(
      id: 0,
      name: r'achievementKey',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 1, name: r'synced', type: IsarType.bool),
    r'unlocked': PropertySchema(id: 2, name: r'unlocked', type: IsarType.bool),
    r'unlockedAt': PropertySchema(
      id: 3,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _achievementStateEstimateSize,
  serialize: _achievementStateSerialize,
  deserialize: _achievementStateDeserialize,
  deserializeProp: _achievementStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'achievementKey': IndexSchema(
      id: -868907934903663033,
      name: r'achievementKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'achievementKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _achievementStateGetId,
  getLinks: _achievementStateGetLinks,
  attach: _achievementStateAttach,
  version: '3.3.2',
);

int _achievementStateEstimateSize(
  AchievementState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.achievementKey.length * 3;
  return bytesCount;
}

void _achievementStateSerialize(
  AchievementState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.achievementKey);
  writer.writeBool(offsets[1], object.synced);
  writer.writeBool(offsets[2], object.unlocked);
  writer.writeDateTime(offsets[3], object.unlockedAt);
}

AchievementState _achievementStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AchievementState();
  object.achievementKey = reader.readString(offsets[0]);
  object.id = id;
  object.synced = reader.readBool(offsets[1]);
  object.unlocked = reader.readBool(offsets[2]);
  object.unlockedAt = reader.readDateTimeOrNull(offsets[3]);
  return object;
}

P _achievementStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _achievementStateGetId(AchievementState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _achievementStateGetLinks(AchievementState object) {
  return [];
}

void _achievementStateAttach(
  IsarCollection<dynamic> col,
  Id id,
  AchievementState object,
) {
  object.id = id;
}

extension AchievementStateByIndex on IsarCollection<AchievementState> {
  Future<AchievementState?> getByAchievementKey(String achievementKey) {
    return getByIndex(r'achievementKey', [achievementKey]);
  }

  AchievementState? getByAchievementKeySync(String achievementKey) {
    return getByIndexSync(r'achievementKey', [achievementKey]);
  }

  Future<bool> deleteByAchievementKey(String achievementKey) {
    return deleteByIndex(r'achievementKey', [achievementKey]);
  }

  bool deleteByAchievementKeySync(String achievementKey) {
    return deleteByIndexSync(r'achievementKey', [achievementKey]);
  }

  Future<List<AchievementState?>> getAllByAchievementKey(
    List<String> achievementKeyValues,
  ) {
    final values = achievementKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'achievementKey', values);
  }

  List<AchievementState?> getAllByAchievementKeySync(
    List<String> achievementKeyValues,
  ) {
    final values = achievementKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'achievementKey', values);
  }

  Future<int> deleteAllByAchievementKey(List<String> achievementKeyValues) {
    final values = achievementKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'achievementKey', values);
  }

  int deleteAllByAchievementKeySync(List<String> achievementKeyValues) {
    final values = achievementKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'achievementKey', values);
  }

  Future<Id> putByAchievementKey(AchievementState object) {
    return putByIndex(r'achievementKey', object);
  }

  Id putByAchievementKeySync(AchievementState object, {bool saveLinks = true}) {
    return putByIndexSync(r'achievementKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAchievementKey(List<AchievementState> objects) {
    return putAllByIndex(r'achievementKey', objects);
  }

  List<Id> putAllByAchievementKeySync(
    List<AchievementState> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'achievementKey', objects, saveLinks: saveLinks);
  }
}

extension AchievementStateQueryWhereSort
    on QueryBuilder<AchievementState, AchievementState, QWhere> {
  QueryBuilder<AchievementState, AchievementState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AchievementStateQueryWhere
    on QueryBuilder<AchievementState, AchievementState, QWhereClause> {
  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause>
  achievementKeyEqualTo(String achievementKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'achievementKey',
          value: [achievementKey],
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterWhereClause>
  achievementKeyNotEqualTo(String achievementKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'achievementKey',
                lower: [],
                upper: [achievementKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'achievementKey',
                lower: [achievementKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'achievementKey',
                lower: [achievementKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'achievementKey',
                lower: [],
                upper: [achievementKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AchievementStateQueryFilter
    on QueryBuilder<AchievementState, AchievementState, QFilterCondition> {
  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'achievementKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'achievementKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'achievementKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'achievementKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'achievementKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'achievementKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'achievementKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'achievementKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'achievementKey', value: ''),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  achievementKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'achievementKey', value: ''),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unlocked', value: value),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'unlockedAt'),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'unlockedAt'),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unlockedAt', value: value),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unlockedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unlockedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterFilterCondition>
  unlockedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unlockedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AchievementStateQueryObject
    on QueryBuilder<AchievementState, AchievementState, QFilterCondition> {}

extension AchievementStateQueryLinks
    on QueryBuilder<AchievementState, AchievementState, QFilterCondition> {}

extension AchievementStateQuerySortBy
    on QueryBuilder<AchievementState, AchievementState, QSortBy> {
  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortByAchievementKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementKey', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortByAchievementKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementKey', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortByUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortByUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementStateQuerySortThenBy
    on QueryBuilder<AchievementState, AchievementState, QSortThenBy> {
  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByAchievementKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementKey', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByAchievementKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'achievementKey', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByUnlockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlocked', Sort.desc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<AchievementState, AchievementState, QAfterSortBy>
  thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension AchievementStateQueryWhereDistinct
    on QueryBuilder<AchievementState, AchievementState, QDistinct> {
  QueryBuilder<AchievementState, AchievementState, QDistinct>
  distinctByAchievementKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'achievementKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AchievementState, AchievementState, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<AchievementState, AchievementState, QDistinct>
  distinctByUnlocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlocked');
    });
  }

  QueryBuilder<AchievementState, AchievementState, QDistinct>
  distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension AchievementStateQueryProperty
    on QueryBuilder<AchievementState, AchievementState, QQueryProperty> {
  QueryBuilder<AchievementState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AchievementState, String, QQueryOperations>
  achievementKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'achievementKey');
    });
  }

  QueryBuilder<AchievementState, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<AchievementState, bool, QQueryOperations> unlockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlocked');
    });
  }

  QueryBuilder<AchievementState, DateTime?, QQueryOperations>
  unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationPreferenceCollection on Isar {
  IsarCollection<NotificationPreference> get notificationPreferences =>
      this.collection();
}

const NotificationPreferenceSchema = CollectionSchema(
  name: r'NotificationPreference',
  id: -6851406387494827683,
  properties: {
    r'dailyCheckInEnabled': PropertySchema(
      id: 0,
      name: r'dailyCheckInEnabled',
      type: IsarType.bool,
    ),
    r'dailyCheckInHour': PropertySchema(
      id: 1,
      name: r'dailyCheckInHour',
      type: IsarType.long,
    ),
    r'dailyCheckInMinute': PropertySchema(
      id: 2,
      name: r'dailyCheckInMinute',
      type: IsarType.long,
    ),
    r'milestoneReminderEnabled': PropertySchema(
      id: 3,
      name: r'milestoneReminderEnabled',
      type: IsarType.bool,
    ),
    r'streakProtectionEnabled': PropertySchema(
      id: 4,
      name: r'streakProtectionEnabled',
      type: IsarType.bool,
    ),
    r'synced': PropertySchema(id: 5, name: r'synced', type: IsarType.bool),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _notificationPreferenceEstimateSize,
  serialize: _notificationPreferenceSerialize,
  deserialize: _notificationPreferenceDeserialize,
  deserializeProp: _notificationPreferenceDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _notificationPreferenceGetId,
  getLinks: _notificationPreferenceGetLinks,
  attach: _notificationPreferenceAttach,
  version: '3.3.2',
);

int _notificationPreferenceEstimateSize(
  NotificationPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _notificationPreferenceSerialize(
  NotificationPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.dailyCheckInEnabled);
  writer.writeLong(offsets[1], object.dailyCheckInHour);
  writer.writeLong(offsets[2], object.dailyCheckInMinute);
  writer.writeBool(offsets[3], object.milestoneReminderEnabled);
  writer.writeBool(offsets[4], object.streakProtectionEnabled);
  writer.writeBool(offsets[5], object.synced);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

NotificationPreference _notificationPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationPreference();
  object.dailyCheckInEnabled = reader.readBool(offsets[0]);
  object.dailyCheckInHour = reader.readLong(offsets[1]);
  object.dailyCheckInMinute = reader.readLong(offsets[2]);
  object.id = id;
  object.milestoneReminderEnabled = reader.readBool(offsets[3]);
  object.streakProtectionEnabled = reader.readBool(offsets[4]);
  object.synced = reader.readBool(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _notificationPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationPreferenceGetId(NotificationPreference object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationPreferenceGetLinks(
  NotificationPreference object,
) {
  return [];
}

void _notificationPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  NotificationPreference object,
) {
  object.id = id;
}

extension NotificationPreferenceQueryWhereSort
    on QueryBuilder<NotificationPreference, NotificationPreference, QWhere> {
  QueryBuilder<NotificationPreference, NotificationPreference, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationPreferenceQueryWhere
    on
        QueryBuilder<
          NotificationPreference,
          NotificationPreference,
          QWhereClause
        > {
  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterWhereClause
  >
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterWhereClause
  >
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NotificationPreferenceQueryFilter
    on
        QueryBuilder<
          NotificationPreference,
          NotificationPreference,
          QFilterCondition
        > {
  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dailyCheckInEnabled', value: value),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInHourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dailyCheckInHour', value: value),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInHourGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyCheckInHour',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInHourLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyCheckInHour',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInHourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyCheckInHour',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInMinuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dailyCheckInMinute', value: value),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInMinuteGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dailyCheckInMinute',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInMinuteLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dailyCheckInMinute',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  dailyCheckInMinuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dailyCheckInMinute',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  milestoneReminderEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'milestoneReminderEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  streakProtectionEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'streakProtectionEnabled',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    NotificationPreference,
    NotificationPreference,
    QAfterFilterCondition
  >
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NotificationPreferenceQueryObject
    on
        QueryBuilder<
          NotificationPreference,
          NotificationPreference,
          QFilterCondition
        > {}

extension NotificationPreferenceQueryLinks
    on
        QueryBuilder<
          NotificationPreference,
          NotificationPreference,
          QFilterCondition
        > {}

extension NotificationPreferenceQuerySortBy
    on QueryBuilder<NotificationPreference, NotificationPreference, QSortBy> {
  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByDailyCheckInEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByDailyCheckInEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByDailyCheckInHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByDailyCheckInHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByDailyCheckInMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByDailyCheckInMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByMilestoneReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'milestoneReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByMilestoneReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'milestoneReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByStreakProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakProtectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByStreakProtectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakProtectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NotificationPreferenceQuerySortThenBy
    on
        QueryBuilder<
          NotificationPreference,
          NotificationPreference,
          QSortThenBy
        > {
  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByDailyCheckInEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByDailyCheckInEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByDailyCheckInHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInHour', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByDailyCheckInHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInHour', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByDailyCheckInMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInMinute', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByDailyCheckInMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyCheckInMinute', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByMilestoneReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'milestoneReminderEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByMilestoneReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'milestoneReminderEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByStreakProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakProtectionEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByStreakProtectionEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streakProtectionEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NotificationPreferenceQueryWhereDistinct
    on QueryBuilder<NotificationPreference, NotificationPreference, QDistinct> {
  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctByDailyCheckInEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCheckInEnabled');
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctByDailyCheckInHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCheckInHour');
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctByDailyCheckInMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyCheckInMinute');
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctByMilestoneReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'milestoneReminderEnabled');
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctByStreakProtectionEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streakProtectionEnabled');
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<NotificationPreference, NotificationPreference, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension NotificationPreferenceQueryProperty
    on
        QueryBuilder<
          NotificationPreference,
          NotificationPreference,
          QQueryProperty
        > {
  QueryBuilder<NotificationPreference, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationPreference, bool, QQueryOperations>
  dailyCheckInEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCheckInEnabled');
    });
  }

  QueryBuilder<NotificationPreference, int, QQueryOperations>
  dailyCheckInHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCheckInHour');
    });
  }

  QueryBuilder<NotificationPreference, int, QQueryOperations>
  dailyCheckInMinuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyCheckInMinute');
    });
  }

  QueryBuilder<NotificationPreference, bool, QQueryOperations>
  milestoneReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'milestoneReminderEnabled');
    });
  }

  QueryBuilder<NotificationPreference, bool, QQueryOperations>
  streakProtectionEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streakProtectionEnabled');
    });
  }

  QueryBuilder<NotificationPreference, bool, QQueryOperations>
  syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<NotificationPreference, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncQueueItemCollection on Isar {
  IsarCollection<SyncQueueItem> get syncQueueItems => this.collection();
}

const SyncQueueItemSchema = CollectionSchema(
  name: r'SyncQueueItem',
  id: 599395208720970483,
  properties: {
    r'attemptCount': PropertySchema(
      id: 0,
      name: r'attemptCount',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'entityId': PropertySchema(
      id: 2,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 3,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 4,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'operation': PropertySchema(
      id: 5,
      name: r'operation',
      type: IsarType.string,
    ),
  },

  estimateSize: _syncQueueItemEstimateSize,
  serialize: _syncQueueItemSerialize,
  deserialize: _syncQueueItemDeserialize,
  deserializeProp: _syncQueueItemDeserializeProp,
  idName: r'id',
  indexes: {
    r'entityType': IndexSchema(
      id: -5109706325448941117,
      name: r'entityType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityType',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _syncQueueItemGetId,
  getLinks: _syncQueueItemGetLinks,
  attach: _syncQueueItemAttach,
  version: '3.3.2',
);

int _syncQueueItemEstimateSize(
  SyncQueueItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.operation.length * 3;
  return bytesCount;
}

void _syncQueueItemSerialize(
  SyncQueueItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attemptCount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.entityId);
  writer.writeString(offsets[3], object.entityType);
  writer.writeString(offsets[4], object.lastError);
  writer.writeString(offsets[5], object.operation);
}

SyncQueueItem _syncQueueItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncQueueItem();
  object.attemptCount = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.entityId = reader.readString(offsets[2]);
  object.entityType = reader.readString(offsets[3]);
  object.id = id;
  object.lastError = reader.readStringOrNull(offsets[4]);
  object.operation = reader.readString(offsets[5]);
  return object;
}

P _syncQueueItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncQueueItemGetId(SyncQueueItem object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncQueueItemGetLinks(SyncQueueItem object) {
  return [];
}

void _syncQueueItemAttach(
  IsarCollection<dynamic> col,
  Id id,
  SyncQueueItem object,
) {
  object.id = id;
}

extension SyncQueueItemQueryWhereSort
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QWhere> {
  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncQueueItemQueryWhere
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QWhereClause> {
  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause>
  entityTypeEqualTo(String entityType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entityType', value: [entityType]),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterWhereClause>
  entityTypeNotEqualTo(String entityType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityType',
                lower: [],
                upper: [entityType],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityType',
                lower: [entityType],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityType',
                lower: [entityType],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityType',
                lower: [],
                upper: [entityType],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SyncQueueItemQueryFilter
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QFilterCondition> {
  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  attemptCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'attemptCount', value: value),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  attemptCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'attemptCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  attemptCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'attemptCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  attemptCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'attemptCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityId', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityType', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'operation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'operation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'operation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'operation', value: ''),
      );
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterFilterCondition>
  operationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'operation', value: ''),
      );
    });
  }
}

extension SyncQueueItemQueryObject
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QFilterCondition> {}

extension SyncQueueItemQueryLinks
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QFilterCondition> {}

extension SyncQueueItemQuerySortBy
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QSortBy> {
  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> sortByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  sortByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }
}

extension SyncQueueItemQuerySortThenBy
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QSortThenBy> {
  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy> thenByOperation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.asc);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QAfterSortBy>
  thenByOperationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operation', Sort.desc);
    });
  }
}

extension SyncQueueItemQueryWhereDistinct
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct> {
  QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct>
  distinctByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptCount');
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct> distinctByEntityId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct> distinctByEntityType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct> distinctByLastError({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncQueueItem, SyncQueueItem, QDistinct> distinctByOperation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operation', caseSensitive: caseSensitive);
    });
  }
}

extension SyncQueueItemQueryProperty
    on QueryBuilder<SyncQueueItem, SyncQueueItem, QQueryProperty> {
  QueryBuilder<SyncQueueItem, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncQueueItem, int, QQueryOperations> attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptCount');
    });
  }

  QueryBuilder<SyncQueueItem, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SyncQueueItem, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<SyncQueueItem, String, QQueryOperations> entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<SyncQueueItem, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<SyncQueueItem, String, QQueryOperations> operationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operation');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalAppEventCollection on Isar {
  IsarCollection<LocalAppEvent> get localAppEvents => this.collection();
}

const LocalAppEventSchema = CollectionSchema(
  name: r'LocalAppEvent',
  id: -8719489334690470435,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'eventId': PropertySchema(id: 1, name: r'eventId', type: IsarType.string),
    r'eventName': PropertySchema(
      id: 2,
      name: r'eventName',
      type: IsarType.string,
    ),
    r'propertiesJson': PropertySchema(
      id: 3,
      name: r'propertiesJson',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 4, name: r'synced', type: IsarType.bool),
  },

  estimateSize: _localAppEventEstimateSize,
  serialize: _localAppEventSerialize,
  deserialize: _localAppEventDeserialize,
  deserializeProp: _localAppEventDeserializeProp,
  idName: r'id',
  indexes: {
    r'eventId': IndexSchema(
      id: -2707901133518603130,
      name: r'eventId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'eventId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _localAppEventGetId,
  getLinks: _localAppEventGetLinks,
  attach: _localAppEventAttach,
  version: '3.3.2',
);

int _localAppEventEstimateSize(
  LocalAppEvent object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.eventId.length * 3;
  bytesCount += 3 + object.eventName.length * 3;
  bytesCount += 3 + object.propertiesJson.length * 3;
  return bytesCount;
}

void _localAppEventSerialize(
  LocalAppEvent object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.eventId);
  writer.writeString(offsets[2], object.eventName);
  writer.writeString(offsets[3], object.propertiesJson);
  writer.writeBool(offsets[4], object.synced);
}

LocalAppEvent _localAppEventDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalAppEvent();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.eventId = reader.readString(offsets[1]);
  object.eventName = reader.readString(offsets[2]);
  object.id = id;
  object.propertiesJson = reader.readString(offsets[3]);
  object.synced = reader.readBool(offsets[4]);
  return object;
}

P _localAppEventDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localAppEventGetId(LocalAppEvent object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localAppEventGetLinks(LocalAppEvent object) {
  return [];
}

void _localAppEventAttach(
  IsarCollection<dynamic> col,
  Id id,
  LocalAppEvent object,
) {
  object.id = id;
}

extension LocalAppEventByIndex on IsarCollection<LocalAppEvent> {
  Future<LocalAppEvent?> getByEventId(String eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  LocalAppEvent? getByEventIdSync(String eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(String eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(String eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<LocalAppEvent?>> getAllByEventId(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<LocalAppEvent?> getAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'eventId', values);
  }

  Future<int> deleteAllByEventId(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'eventId', values);
  }

  int deleteAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'eventId', values);
  }

  Future<Id> putByEventId(LocalAppEvent object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(LocalAppEvent object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<LocalAppEvent> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(
    List<LocalAppEvent> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension LocalAppEventQueryWhereSort
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QWhere> {
  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalAppEventQueryWhere
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QWhereClause> {
  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause> eventIdEqualTo(
    String eventId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eventId', value: [eventId]),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterWhereClause>
  eventIdNotEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LocalAppEventQueryFilter
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QFilterCondition> {
  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eventId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'eventId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventId', value: ''),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'eventId', value: ''),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eventName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eventName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eventName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eventName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'eventName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'eventName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'eventName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'eventName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventName', value: ''),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  eventNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'eventName', value: ''),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'propertiesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'propertiesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'propertiesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'propertiesJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'propertiesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'propertiesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'propertiesJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'propertiesJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'propertiesJson', value: ''),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  propertiesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'propertiesJson', value: ''),
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }
}

extension LocalAppEventQueryObject
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QFilterCondition> {}

extension LocalAppEventQueryLinks
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QFilterCondition> {}

extension LocalAppEventQuerySortBy
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QSortBy> {
  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> sortByEventName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  sortByEventNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  sortByPropertiesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertiesJson', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  sortByPropertiesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertiesJson', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension LocalAppEventQuerySortThenBy
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QSortThenBy> {
  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenByEventName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  thenByEventNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  thenByPropertiesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertiesJson', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy>
  thenByPropertiesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertiesJson', Sort.desc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }
}

extension LocalAppEventQueryWhereDistinct
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QDistinct> {
  QueryBuilder<LocalAppEvent, LocalAppEvent, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QDistinct> distinctByEventId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QDistinct> distinctByEventName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QDistinct>
  distinctByPropertiesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'propertiesJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalAppEvent, LocalAppEvent, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }
}

extension LocalAppEventQueryProperty
    on QueryBuilder<LocalAppEvent, LocalAppEvent, QQueryProperty> {
  QueryBuilder<LocalAppEvent, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalAppEvent, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LocalAppEvent, String, QQueryOperations> eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<LocalAppEvent, String, QQueryOperations> eventNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventName');
    });
  }

  QueryBuilder<LocalAppEvent, String, QQueryOperations>
  propertiesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'propertiesJson');
    });
  }

  QueryBuilder<LocalAppEvent, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }
}
