// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_surplus_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthlySurplusModelCollection on Isar {
  IsarCollection<MonthlySurplusModel> get monthlySurplusModels =>
      this.collection();
}

const MonthlySurplusModelSchema = CollectionSchema(
  name: r'MonthlySurplusModel',
  id: 2479579043658879978,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expense': PropertySchema(
      id: 2,
      name: r'expense',
      type: IsarType.double,
    ),
    r'income': PropertySchema(
      id: 3,
      name: r'income',
      type: IsarType.double,
    ),
    r'monthYear': PropertySchema(
      id: 4,
      name: r'monthYear',
      type: IsarType.dateTime,
    ),
    r'surplus': PropertySchema(
      id: 5,
      name: r'surplus',
      type: IsarType.double,
    )
  },
  estimateSize: _monthlySurplusModelEstimateSize,
  serialize: _monthlySurplusModelSerialize,
  deserialize: _monthlySurplusModelDeserialize,
  deserializeProp: _monthlySurplusModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'monthYear': IndexSchema(
      id: -8729709491572084802,
      name: r'monthYear',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'monthYear',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _monthlySurplusModelGetId,
  getLinks: _monthlySurplusModelGetLinks,
  attach: _monthlySurplusModelAttach,
  version: '3.1.0+1',
);

int _monthlySurplusModelEstimateSize(
  MonthlySurplusModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _monthlySurplusModelSerialize(
  MonthlySurplusModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.action);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.expense);
  writer.writeDouble(offsets[3], object.income);
  writer.writeDateTime(offsets[4], object.monthYear);
  writer.writeDouble(offsets[5], object.surplus);
}

MonthlySurplusModel _monthlySurplusModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthlySurplusModel();
  object.action = reader.readLong(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.expense = reader.readDouble(offsets[2]);
  object.id = id;
  object.income = reader.readDouble(offsets[3]);
  object.monthYear = reader.readDateTime(offsets[4]);
  object.surplus = reader.readDouble(offsets[5]);
  return object;
}

P _monthlySurplusModelDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _monthlySurplusModelGetId(MonthlySurplusModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthlySurplusModelGetLinks(
    MonthlySurplusModel object) {
  return [];
}

void _monthlySurplusModelAttach(
    IsarCollection<dynamic> col, Id id, MonthlySurplusModel object) {
  object.id = id;
}

extension MonthlySurplusModelQueryWhereSort
    on QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QWhere> {
  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhere>
      anyMonthYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'monthYear'),
      );
    });
  }
}

extension MonthlySurplusModelQueryWhere
    on QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QWhereClause> {
  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
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

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
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

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      monthYearEqualTo(DateTime monthYear) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'monthYear',
        value: [monthYear],
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      monthYearNotEqualTo(DateTime monthYear) {
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

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      monthYearGreaterThan(
    DateTime monthYear, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'monthYear',
        lower: [monthYear],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      monthYearLessThan(
    DateTime monthYear, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'monthYear',
        lower: [],
        upper: [monthYear],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterWhereClause>
      monthYearBetween(
    DateTime lowerMonthYear,
    DateTime upperMonthYear, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'monthYear',
        lower: [lowerMonthYear],
        includeLower: includeLower,
        upper: [upperMonthYear],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MonthlySurplusModelQueryFilter on QueryBuilder<MonthlySurplusModel,
    MonthlySurplusModel, QFilterCondition> {
  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      actionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      actionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      actionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      actionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      expenseEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      expenseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      expenseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expense',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      expenseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expense',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
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

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
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

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
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

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      incomeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'income',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      incomeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'income',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      incomeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'income',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      incomeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'income',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      monthYearEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthYear',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      monthYearGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthYear',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      monthYearLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthYear',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      monthYearBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      surplusEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surplus',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      surplusGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surplus',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      surplusLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surplus',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterFilterCondition>
      surplusBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surplus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MonthlySurplusModelQueryObject on QueryBuilder<MonthlySurplusModel,
    MonthlySurplusModel, QFilterCondition> {}

extension MonthlySurplusModelQueryLinks on QueryBuilder<MonthlySurplusModel,
    MonthlySurplusModel, QFilterCondition> {}

extension MonthlySurplusModelQuerySortBy
    on QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QSortBy> {
  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expense', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByExpenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expense', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'income', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'income', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByMonthYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortByMonthYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortBySurplus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surplus', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      sortBySurplusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surplus', Sort.desc);
    });
  }
}

extension MonthlySurplusModelQuerySortThenBy
    on QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QSortThenBy> {
  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expense', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByExpenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expense', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'income', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByIncomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'income', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByMonthYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenByMonthYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthYear', Sort.desc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenBySurplus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surplus', Sort.asc);
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QAfterSortBy>
      thenBySurplusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surplus', Sort.desc);
    });
  }
}

extension MonthlySurplusModelQueryWhereDistinct
    on QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct> {
  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct>
      distinctByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action');
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct>
      distinctByExpense() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expense');
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct>
      distinctByIncome() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'income');
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct>
      distinctByMonthYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthYear');
    });
  }

  QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QDistinct>
      distinctBySurplus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surplus');
    });
  }
}

extension MonthlySurplusModelQueryProperty
    on QueryBuilder<MonthlySurplusModel, MonthlySurplusModel, QQueryProperty> {
  QueryBuilder<MonthlySurplusModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthlySurplusModel, int, QQueryOperations> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<MonthlySurplusModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MonthlySurplusModel, double, QQueryOperations>
      expenseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expense');
    });
  }

  QueryBuilder<MonthlySurplusModel, double, QQueryOperations> incomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'income');
    });
  }

  QueryBuilder<MonthlySurplusModel, DateTime, QQueryOperations>
      monthYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthYear');
    });
  }

  QueryBuilder<MonthlySurplusModel, double, QQueryOperations>
      surplusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surplus');
    });
  }
}
