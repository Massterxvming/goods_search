/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class PriceObservation
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PriceObservation._({
    this.id,
    required this.queryKey,
    required this.observationKey,
    required this.platform,
    required this.productId,
    required this.sourceUrl,
    required this.seller,
    required this.priceCents,
    required this.priceText,
    required this.observedAt,
  });

  factory PriceObservation({
    int? id,
    required String queryKey,
    required String observationKey,
    required String platform,
    required String productId,
    required String sourceUrl,
    required String seller,
    required int priceCents,
    required String priceText,
    required DateTime observedAt,
  }) = _PriceObservationImpl;

  factory PriceObservation.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceObservation(
      id: jsonSerialization['id'] as int?,
      queryKey: jsonSerialization['queryKey'] as String,
      observationKey: jsonSerialization['observationKey'] as String,
      platform: jsonSerialization['platform'] as String,
      productId: jsonSerialization['productId'] as String,
      sourceUrl: jsonSerialization['sourceUrl'] as String,
      seller: jsonSerialization['seller'] as String,
      priceCents: jsonSerialization['priceCents'] as int,
      priceText: jsonSerialization['priceText'] as String,
      observedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['observedAt'],
      ),
    );
  }

  static final t = PriceObservationTable();

  static const db = PriceObservationRepository._();

  @override
  int? id;

  String queryKey;

  String observationKey;

  String platform;

  String productId;

  String sourceUrl;

  String seller;

  int priceCents;

  String priceText;

  DateTime observedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PriceObservation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceObservation copyWith({
    int? id,
    String? queryKey,
    String? observationKey,
    String? platform,
    String? productId,
    String? sourceUrl,
    String? seller,
    int? priceCents,
    String? priceText,
    DateTime? observedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceObservation',
      if (id != null) 'id': id,
      'queryKey': queryKey,
      'observationKey': observationKey,
      'platform': platform,
      'productId': productId,
      'sourceUrl': sourceUrl,
      'seller': seller,
      'priceCents': priceCents,
      'priceText': priceText,
      'observedAt': observedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PriceObservationInclude include() {
    return PriceObservationInclude._();
  }

  static PriceObservationIncludeList includeList({
    _i1.WhereExpressionBuilder<PriceObservationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PriceObservationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PriceObservationTable>? orderByList,
    PriceObservationInclude? include,
  }) {
    return PriceObservationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PriceObservation.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PriceObservation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PriceObservationImpl extends PriceObservation {
  _PriceObservationImpl({
    int? id,
    required String queryKey,
    required String observationKey,
    required String platform,
    required String productId,
    required String sourceUrl,
    required String seller,
    required int priceCents,
    required String priceText,
    required DateTime observedAt,
  }) : super._(
         id: id,
         queryKey: queryKey,
         observationKey: observationKey,
         platform: platform,
         productId: productId,
         sourceUrl: sourceUrl,
         seller: seller,
         priceCents: priceCents,
         priceText: priceText,
         observedAt: observedAt,
       );

  /// Returns a shallow copy of this [PriceObservation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceObservation copyWith({
    Object? id = _Undefined,
    String? queryKey,
    String? observationKey,
    String? platform,
    String? productId,
    String? sourceUrl,
    String? seller,
    int? priceCents,
    String? priceText,
    DateTime? observedAt,
  }) {
    return PriceObservation(
      id: id is int? ? id : this.id,
      queryKey: queryKey ?? this.queryKey,
      observationKey: observationKey ?? this.observationKey,
      platform: platform ?? this.platform,
      productId: productId ?? this.productId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      seller: seller ?? this.seller,
      priceCents: priceCents ?? this.priceCents,
      priceText: priceText ?? this.priceText,
      observedAt: observedAt ?? this.observedAt,
    );
  }
}

class PriceObservationUpdateTable
    extends _i1.UpdateTable<PriceObservationTable> {
  PriceObservationUpdateTable(super.table);

  _i1.ColumnValue<String, String> queryKey(String value) => _i1.ColumnValue(
    table.queryKey,
    value,
  );

  _i1.ColumnValue<String, String> observationKey(String value) =>
      _i1.ColumnValue(
        table.observationKey,
        value,
      );

  _i1.ColumnValue<String, String> platform(String value) => _i1.ColumnValue(
    table.platform,
    value,
  );

  _i1.ColumnValue<String, String> productId(String value) => _i1.ColumnValue(
    table.productId,
    value,
  );

  _i1.ColumnValue<String, String> sourceUrl(String value) => _i1.ColumnValue(
    table.sourceUrl,
    value,
  );

  _i1.ColumnValue<String, String> seller(String value) => _i1.ColumnValue(
    table.seller,
    value,
  );

  _i1.ColumnValue<int, int> priceCents(int value) => _i1.ColumnValue(
    table.priceCents,
    value,
  );

  _i1.ColumnValue<String, String> priceText(String value) => _i1.ColumnValue(
    table.priceText,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> observedAt(DateTime value) =>
      _i1.ColumnValue(
        table.observedAt,
        value,
      );
}

class PriceObservationTable extends _i1.Table<int?> {
  PriceObservationTable({super.tableRelation})
    : super(tableName: 'price_observation') {
    updateTable = PriceObservationUpdateTable(this);
    queryKey = _i1.ColumnString(
      'queryKey',
      this,
    );
    observationKey = _i1.ColumnString(
      'observationKey',
      this,
    );
    platform = _i1.ColumnString(
      'platform',
      this,
    );
    productId = _i1.ColumnString(
      'productId',
      this,
    );
    sourceUrl = _i1.ColumnString(
      'sourceUrl',
      this,
    );
    seller = _i1.ColumnString(
      'seller',
      this,
    );
    priceCents = _i1.ColumnInt(
      'priceCents',
      this,
    );
    priceText = _i1.ColumnString(
      'priceText',
      this,
    );
    observedAt = _i1.ColumnDateTime(
      'observedAt',
      this,
    );
  }

  late final PriceObservationUpdateTable updateTable;

  late final _i1.ColumnString queryKey;

  late final _i1.ColumnString observationKey;

  late final _i1.ColumnString platform;

  late final _i1.ColumnString productId;

  late final _i1.ColumnString sourceUrl;

  late final _i1.ColumnString seller;

  late final _i1.ColumnInt priceCents;

  late final _i1.ColumnString priceText;

  late final _i1.ColumnDateTime observedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    queryKey,
    observationKey,
    platform,
    productId,
    sourceUrl,
    seller,
    priceCents,
    priceText,
    observedAt,
  ];
}

class PriceObservationInclude extends _i1.IncludeObject {
  PriceObservationInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PriceObservation.t;
}

class PriceObservationIncludeList extends _i1.IncludeList {
  PriceObservationIncludeList._({
    _i1.WhereExpressionBuilder<PriceObservationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PriceObservation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PriceObservation.t;
}

class PriceObservationRepository {
  const PriceObservationRepository._();

  /// Returns a list of [PriceObservation]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<PriceObservation>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PriceObservationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PriceObservationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PriceObservationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PriceObservation>(
      where: where?.call(PriceObservation.t),
      orderBy: orderBy?.call(PriceObservation.t),
      orderByList: orderByList?.call(PriceObservation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PriceObservation] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<PriceObservation?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PriceObservationTable>? where,
    int? offset,
    _i1.OrderByBuilder<PriceObservationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PriceObservationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PriceObservation>(
      where: where?.call(PriceObservation.t),
      orderBy: orderBy?.call(PriceObservation.t),
      orderByList: orderByList?.call(PriceObservation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PriceObservation] by its [id] or null if no such row exists.
  Future<PriceObservation?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PriceObservation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PriceObservation]s in the list and returns the inserted rows.
  ///
  /// The returned [PriceObservation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PriceObservation>> insert(
    _i1.DatabaseSession session,
    List<PriceObservation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PriceObservation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PriceObservation] and returns the inserted row.
  ///
  /// The returned [PriceObservation] will have its `id` field set.
  Future<PriceObservation> insertRow(
    _i1.DatabaseSession session,
    PriceObservation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PriceObservation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PriceObservation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PriceObservation>> update(
    _i1.DatabaseSession session,
    List<PriceObservation> rows, {
    _i1.ColumnSelections<PriceObservationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PriceObservation>(
      rows,
      columns: columns?.call(PriceObservation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PriceObservation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PriceObservation> updateRow(
    _i1.DatabaseSession session,
    PriceObservation row, {
    _i1.ColumnSelections<PriceObservationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PriceObservation>(
      row,
      columns: columns?.call(PriceObservation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PriceObservation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PriceObservation?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PriceObservationUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PriceObservation>(
      id,
      columnValues: columnValues(PriceObservation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PriceObservation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PriceObservation>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PriceObservationUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PriceObservationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PriceObservationTable>? orderBy,
    _i1.OrderByListBuilder<PriceObservationTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PriceObservation>(
      columnValues: columnValues(PriceObservation.t.updateTable),
      where: where(PriceObservation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PriceObservation.t),
      orderByList: orderByList?.call(PriceObservation.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PriceObservation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PriceObservation>> delete(
    _i1.DatabaseSession session,
    List<PriceObservation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PriceObservation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PriceObservation].
  Future<PriceObservation> deleteRow(
    _i1.DatabaseSession session,
    PriceObservation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PriceObservation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PriceObservation>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PriceObservationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PriceObservation>(
      where: where(PriceObservation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PriceObservationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PriceObservation>(
      where: where?.call(PriceObservation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PriceObservation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PriceObservationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PriceObservation>(
      where: where(PriceObservation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
