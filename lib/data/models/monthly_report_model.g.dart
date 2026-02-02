// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_report_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthlyReportModelCollection on Isar {
  IsarCollection<MonthlyReportModel> get monthlyReportModels =>
      this.collection();
}

const MonthlyReportModelSchema = CollectionSchema(
  name: r'MonthlyReportModel',
  id: -4963278967810671206,
  properties: {
    r'closingBalance': PropertySchema(
      id: 0,
      name: r'closingBalance',
      type: IsarType.double,
    ),
    r'monthYear': PropertySchema(
      id: 1,
      name: r'monthYear',
      type: IsarType.string,
    ),
    r'openingBalance': PropertySchema(
      id: 2,
      name: r'openingBalance',
      type: IsarType.double,
    ),
    r'totalExpense': PropertySchema(
      id: 3,
      name: r'totalExpense',
      type: IsarType.double,
    ),
    r'totalIncome': PropertySchema(
      id: 4,
      name: r'totalIncome',
      type: IsarType.double,
    )
  },
  estimateSize: _monthlyReportModelEstimateSize,
  serialize: _monthlyReportModelSerialize,
  deserialize: _monthlyReportModelDeserialize,
  deserializeProp: _monthlyReportModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'monthYear': IndexSchema(
      id: -8729709491572084802,
      name: r'monthYear',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'monthYear',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _monthlyReportModelGetId,
  getLinks: _monthlyReportModelGetLinks,
  attach: _monthlyReportModelAttach,
  version: '3.1.0+1',
);

int _monthlyReportModelEstimateSize(
  MonthlyReportModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.monthYear.length * 3;
  return bytesCount;
}

void _monthlyReportModelSerialize(
  MonthlyReportModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.closingBalance);
  writer.writeString(offsets[1], object.monthYear);
  writer.writeDouble(offsets[2], object.openingBalance);
  writer.writeDouble(offsets[3], object.totalExpense);
  writer.writeDouble(offsets[4], object.totalIncome);
}

MonthlyReportModel _monthlyReportModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthlyReportModel();
  object.closingBalance = reader.readDouble(offsets[0]);
  object.id = id;
  object.monthYear = reader.readString(offsets[1]);
  object.openingBalance = reader.readDouble(offsets[2]);
  object.totalExpense = reader.readDouble(offsets[3]);
  object.totalIncome = reader.readDouble(offsets[4]);
  return object;
}

P _monthlyReportModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _monthlyReportModelGetId(MonthlyReportModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthlyReportModelGetLinks(
    MonthlyReportModel object) {
  return [];
}

void _monthlyReportModelAttach(
    IsarCollection<dynamic> col, Id id, MonthlyReportModel object) {
  object.id = id;
}

extension MonthlyReportModelByIndex on IsarCollection<MonthlyReportModel> {
  Future<MonthlyReportModel?> getByMonthYear(String monthYear) {
    return getByIndex(r'monthYear', [monthYear]);
  }

  MonthlyReportModel? getByMonthYearSync(String monthYear) {
    return getByIndexSync(r'monthYear', [monthYear]);
  }

  Future<bool> deleteByMonthYear(String monthYear) {
    return deleteByIndex(r'monthYear', [monthYear]);
  }

  bool deleteByMonthYearSync(String monthYear) {
    return deleteByIndexSync(r'monthYear', [monthYear]);
  }

  Future<List<MonthlyReportModel?>> getAllByMonthYear(
      List<String> monthYearValues) {
    final values = monthYearValues.map((e) => [e]).toList();
    return getAllByIndex(r'monthYear', values);
  }

  List<MonthlyReportModel?> getAllByMonthYearSync(
      List<String> monthYearValues) {
    final values = monthYearValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'monthYear', values);
  }

  Future<int> deleteAllByMonthYear(List<String> monthYearValues) {
    final values = monthYearValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'monthYear', values);
  }

  int deleteAllByMonthYearSync(List<String> monthYearValues) {
    final values = monthYearValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'monthYear', values);
  }

  Future<Id> putByMonthYear(MonthlyReportModel object) {
    return putByIndex(r'monthYear', object);
  }

  Id putByMonthYearSync(MonthlyReportModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'monthYear', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMonthYear(List<MonthlyReportModel> objects) {
    return putAllByIndex(r'monthYear', objects);
  }

  List<Id> putAllByMonthYearSync(List<MonthlyReportModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'monthYear', objects, saveLinks: saveLinks);
  }
}

extension MonthlyReportModelQueryWhereSort
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QWhere> {
  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MonthlyReportModelQueryWhere
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QWhereClause> {
  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
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

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
      monthYearEqualTo(String monthYear) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'monthYear',
        value: [monthYear],
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterWhereClause>
      monthYearNotEqualTo(String monthYear) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthYear',
              lower: [],
              upper: [monthYear],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthYear',
              lower: [monthYear],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthYear',
              lower: [monthYear],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthYear',
              lower: [],
              upper: [monthYear],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MonthlyReportModelQueryFilter
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QFilterCondition> {
  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      closingBalanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      closingBalanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      closingBalanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      closingBalanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closingBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monthYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monthYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monthYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monthYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthYear',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      monthYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monthYear',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      openingBalanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      openingBalanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'openingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      openingBalanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'openingBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      openingBalanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'openingBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalExpenseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalExpense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalExpenseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalExpense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalExpenseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalExpense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalExpenseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalExpense',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalIncomeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalIncome',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalIncomeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalIncome',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalIncomeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalIncome',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterFilterCondition>
      totalIncomeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalIncome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MonthlyReportModelQueryObject
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QFilterCondition> {}

extension MonthlyReportModelQueryLinks
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QFilterCondition> {}

extension MonthlyReportModelQuerySortBy
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QSortBy> {
  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByClosingBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closingBalance', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByClosingBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closingBalance', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByMonthYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByMonthYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByOpeningBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalance', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByOpeningBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalance', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByTotalExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByTotalExpenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByTotalIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIncome', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      sortByTotalIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIncome', Sort.desc);
    });
  }
}

extension MonthlyReportModelQuerySortThenBy
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QSortThenBy> {
  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByClosingBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closingBalance', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByClosingBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closingBalance', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByMonthYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByMonthYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByOpeningBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalance', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByOpeningBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openingBalance', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByTotalExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByTotalExpenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalExpense', Sort.desc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByTotalIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIncome', Sort.asc);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QAfterSortBy>
      thenByTotalIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIncome', Sort.desc);
    });
  }
}

extension MonthlyReportModelQueryWhereDistinct
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QDistinct> {
  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QDistinct>
      distinctByClosingBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closingBalance');
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QDistinct>
      distinctByMonthYear({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QDistinct>
      distinctByOpeningBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openingBalance');
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QDistinct>
      distinctByTotalExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalExpense');
    });
  }

  QueryBuilder<MonthlyReportModel, MonthlyReportModel, QDistinct>
      distinctByTotalIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalIncome');
    });
  }
}

extension MonthlyReportModelQueryProperty
    on QueryBuilder<MonthlyReportModel, MonthlyReportModel, QQueryProperty> {
  QueryBuilder<MonthlyReportModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthlyReportModel, double, QQueryOperations>
      closingBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closingBalance');
    });
  }

  QueryBuilder<MonthlyReportModel, String, QQueryOperations>
      monthYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthYear');
    });
  }

  QueryBuilder<MonthlyReportModel, double, QQueryOperations>
      openingBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openingBalance');
    });
  }

  QueryBuilder<MonthlyReportModel, double, QQueryOperations>
      totalExpenseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalExpense');
    });
  }

  QueryBuilder<MonthlyReportModel, double, QQueryOperations>
      totalIncomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalIncome');
    });
  }
}
