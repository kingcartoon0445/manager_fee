// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_shopping_item_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuickShoppingItemModelCollection on Isar {
  IsarCollection<QuickShoppingItemModel> get quickShoppingItemModels =>
      this.collection();
}

const QuickShoppingItemModelSchema = CollectionSchema(
  name: r'QuickShoppingItemModel',
  id: 3286104533851317292,
  properties: {
    r'colorValue': PropertySchema(
      id: 0,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'dbCategoryId': PropertySchema(
      id: 1,
      name: r'dbCategoryId',
      type: IsarType.long,
    ),
    r'iconCodePoint': PropertySchema(
      id: 2,
      name: r'iconCodePoint',
      type: IsarType.long,
    ),
    r'iconFontFamily': PropertySchema(
      id: 3,
      name: r'iconFontFamily',
      type: IsarType.string,
    ),
    r'iconFontPackage': PropertySchema(
      id: 4,
      name: r'iconFontPackage',
      type: IsarType.string,
    ),
    r'label': PropertySchema(
      id: 5,
      name: r'label',
      type: IsarType.string,
    ),
    r'note': PropertySchema(
      id: 6,
      name: r'note',
      type: IsarType.string,
    )
  },
  estimateSize: _quickShoppingItemModelEstimateSize,
  serialize: _quickShoppingItemModelSerialize,
  deserialize: _quickShoppingItemModelDeserialize,
  deserializeProp: _quickShoppingItemModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _quickShoppingItemModelGetId,
  getLinks: _quickShoppingItemModelGetLinks,
  attach: _quickShoppingItemModelAttach,
  version: '3.1.0+1',
);

int _quickShoppingItemModelEstimateSize(
  QuickShoppingItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.iconFontFamily;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.iconFontPackage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _quickShoppingItemModelSerialize(
  QuickShoppingItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorValue);
  writer.writeLong(offsets[1], object.dbCategoryId);
  writer.writeLong(offsets[2], object.iconCodePoint);
  writer.writeString(offsets[3], object.iconFontFamily);
  writer.writeString(offsets[4], object.iconFontPackage);
  writer.writeString(offsets[5], object.label);
  writer.writeString(offsets[6], object.note);
}

QuickShoppingItemModel _quickShoppingItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuickShoppingItemModel();
  object.colorValue = reader.readLong(offsets[0]);
  object.dbCategoryId = reader.readLong(offsets[1]);
  object.iconCodePoint = reader.readLong(offsets[2]);
  object.iconFontFamily = reader.readStringOrNull(offsets[3]);
  object.iconFontPackage = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.label = reader.readString(offsets[5]);
  object.note = reader.readString(offsets[6]);
  return object;
}

P _quickShoppingItemModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _quickShoppingItemModelGetId(QuickShoppingItemModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _quickShoppingItemModelGetLinks(
    QuickShoppingItemModel object) {
  return [];
}

void _quickShoppingItemModelAttach(
    IsarCollection<dynamic> col, Id id, QuickShoppingItemModel object) {
  object.id = id;
}

extension QuickShoppingItemModelQueryWhereSort
    on QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QWhere> {
  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuickShoppingItemModelQueryWhere on QueryBuilder<
    QuickShoppingItemModel, QuickShoppingItemModel, QWhereClause> {
  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension QuickShoppingItemModelQueryFilter on QueryBuilder<
    QuickShoppingItemModel, QuickShoppingItemModel, QFilterCondition> {
  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> colorValueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> colorValueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorValue',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> colorValueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> dbCategoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dbCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> dbCategoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dbCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> dbCategoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dbCategoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> dbCategoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dbCategoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconCodePointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconCodePointGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconCodePointLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconCodePoint',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconCodePointBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconCodePoint',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'iconFontFamily',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'iconFontFamily',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconFontFamily',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      iconFontFamilyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconFontFamily',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      iconFontFamilyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconFontFamily',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontFamilyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconFontFamily',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'iconFontPackage',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'iconFontPackage',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconFontPackage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      iconFontPackageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconFontPackage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      iconFontPackageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconFontPackage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconFontPackage',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> iconFontPackageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconFontPackage',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
          QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }
}

extension QuickShoppingItemModelQueryObject on QueryBuilder<
    QuickShoppingItemModel, QuickShoppingItemModel, QFilterCondition> {}

extension QuickShoppingItemModelQueryLinks on QueryBuilder<
    QuickShoppingItemModel, QuickShoppingItemModel, QFilterCondition> {}

extension QuickShoppingItemModelQuerySortBy
    on QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QSortBy> {
  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByDbCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbCategoryId', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByDbCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbCategoryId', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByIconFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByIconFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByIconFontPackage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByIconFontPackageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension QuickShoppingItemModelQuerySortThenBy on QueryBuilder<
    QuickShoppingItemModel, QuickShoppingItemModel, QSortThenBy> {
  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByDbCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbCategoryId', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByDbCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbCategoryId', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCodePoint', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIconFontFamily() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIconFontFamilyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontFamily', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIconFontPackage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIconFontPackageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconFontPackage', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension QuickShoppingItemModelQueryWhereDistinct
    on QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct> {
  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByDbCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dbCategoryId');
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCodePoint');
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByIconFontFamily({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconFontFamily',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByIconFontPackage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconFontPackage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuickShoppingItemModel, QuickShoppingItemModel, QDistinct>
      distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }
}

extension QuickShoppingItemModelQueryProperty on QueryBuilder<
    QuickShoppingItemModel, QuickShoppingItemModel, QQueryProperty> {
  QueryBuilder<QuickShoppingItemModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuickShoppingItemModel, int, QQueryOperations>
      colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<QuickShoppingItemModel, int, QQueryOperations>
      dbCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dbCategoryId');
    });
  }

  QueryBuilder<QuickShoppingItemModel, int, QQueryOperations>
      iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCodePoint');
    });
  }

  QueryBuilder<QuickShoppingItemModel, String?, QQueryOperations>
      iconFontFamilyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconFontFamily');
    });
  }

  QueryBuilder<QuickShoppingItemModel, String?, QQueryOperations>
      iconFontPackageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconFontPackage');
    });
  }

  QueryBuilder<QuickShoppingItemModel, String, QQueryOperations>
      labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<QuickShoppingItemModel, String, QQueryOperations>
      noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }
}
