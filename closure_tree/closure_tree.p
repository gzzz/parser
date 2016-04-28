# Класс по работе с closure-table-деревом.

# $ctree[^closure_tree::create[
# 	$.nodes_table[nodes]
# 	$.refs_table[refs]
# 	$.node_fields[
# 		$.id[]
# 		$.title[]
# 		$.slug[]
# 		$.sort_order[]
# 	]
# 	$.sort_field[sort_order]
# ]]

# ^connect[…]{
# 	$tree[^ctree.select(1)]
# }


@CLASS
closure_tree


@OPTIONS
locals


@create[params]
$self.params[^hash::create[$params]]

# Имена таблиц.
$self.nodes_table[$params.nodes_table]
$self.refs_table[$params.refs_table]

# Поля таблицы узлов.
$self.node_fields[
	$.id[id]
]
^self.node_fields.add[^hash::create[$params.node_fields]]

# Поле сортировки узлов.
$self.order_field[$params.order_field]


# manipulation

@insert[node]
# Вставляет новый узел.

$parent_id(^node.parent_id.int(0))

^self._checkParentExist($parent)[insert]

^self._transaction{
	$result(^self._insertNode[$node])

	^if($result){
		$ancestors[^self.ancestors($parent_id)]

		^self._link[
			$.$result[
				$.node_id($result)
			]
		][$ancestors][
			$.with-self(true)
		]
	}
}


@delete[nodes]
# Удаляет узлы.

$result[]

$descendants[^self.descendants[$nodes]]

^if($descendants){
	^self._transaction{
		^self._deleteNodes[$descendants]
		^self._unlink[$descendants]
	}
}


@move[node_id;parent_id]
# Перемещает узел.

$options[^hash::create[$options]]

$node_id(^node_id.int(0))
$parent_id(^parent_id.int(0))

^self._checkParentExist($parent_id)[move]

$descendants[^self.descendants($node_id)[$.with-self(true)]]

^if($descendants){
	^descendants.foreach[;node]{
		^if($node.node_id == $parent_id){
			^throw[${self.CLASS_NAME}.move;;attempt to move a node to self or to descendant]
		}
	}

	$ancestors[^self.ancestors($node_id)[$.with-self(false)]]
	$parent_ancestors[^self.ancestors($parent_id)[$.with-self(true)]]

	^self._transaction{
		^self._unlink[$descendants;$ancestors]
		^self._link[$descendants;$parent_ancestors]
	}
}


# nodes selection

@select[node_id;options]
# Извлекает потомков в виде дерева.

$options[
	^hash::create[$options]
	$.hash-by[parent_id]
]

$result[^self.descendantNodes(^node_id.int(0))[$options]]


@ancestorNodes[nodes;options]
# Извлекает узлы-предки.

$options[
	^hash::create[$options]
	$.with-parent(true)
]

$ancestors[^self.ancestors[$nodes;$options]]

$result[^self.nodes[$ancestors;ancestor_id;$options]]


@descendantNodes[nodes;options]
# Извлекает узлы-потомки.

$options[
	^hash::create[$options]
	$.with-parent(true)
]

$descendants[^self.descendants[$nodes;$options]]

$result[^self.nodes[$descendants;node_id;$options]]


@siblingNodes[nodes;options]
# Извлекает узлы-соседи.

$options[
	^hash::create[$options]
	$.with-parent(true)
]

$siblings[^self.siblings[$nodes;$options]]

$result[^self.nodes[$siblings;node_id;$options]]


@childNodes[nodes;options]
# Извлекает узлы-дети.

$options[
	^hash::create[$options]
	$.with-parent(true)
]

$children[^self.children[$nodes;$options]]

$result[^self.nodes[$children;node_id;$options]]


@parentNodes[nodes;options]
# Извлекает узлы-родители.

$options[
	^hash::create[$options]
	$.with-parent(true)
]

$parents[^self.parents[$nodes;$options]]

$result[^self.nodes[$parents;ancestor_id;$options]]


# references selection

@ancestors[nodes;options]
# Извлекает предков.

$options[^hash::create[$options]]

$result[^table::sql{
	SELECT node_id, ancestor_id, distance
	FROM $self.refs_table
	WHERE 1
		AND node_id IN (^self._list[$nodes;node_id])
		^if(!^options.[with-self].bool(true)){AND distance > 0}
	ORDER BY distance DESC
}[^self._sqlOptions[$options]]]


@descendants[nodes;options]
# Извлекает потомков.

$options[^hash::create[$options]]
$with_parent(^options.[with-parent].bool(false))

$result[^table::sql{
	SELECT
		t.node_id,
		t.ancestor_id,
		t.distance
		^self._parentField($with_parent)
	FROM $self.refs_table AS t
	^self._parentTable($with_parent)
	WHERE 1
		AND t.ancestor_id IN (^self._list[$nodes;node_id])
		^if(!^options.[with-self].bool(true)){AND t.distance > 0}
}[^self._sqlOptions[$options]]]


@siblings[nodes;options]
# Извлекает соседей.

$options[^hash::create[$options]]

$parents[^self.parents[$nodes]]

$result[^table::sql{
	SELECT node_id, ancestor_id, distance
	FROM $self.refs_table
	WHERE 1
		AND ancestor_id IN (^self._list[$parents;ancestor_id])
		AND distance = 1
		^if(!^options.[with-self].bool(true)){AND node_id NOT IN (^self._list[$nodes;node_id])}
}[^self._sqlOptions[$options]]]


@parents[nodes;options]
# Извлекает родителей.

$options[^hash::create[$options]]

$result[^table::sql{
	SELECT node_id, ancestor_id, distance
	FROM $self.refs_table
	WHERE 1
		AND node_id IN (^self._list[$nodes;node_id])
		AND distance = 1
}[^self._sqlOptions[$options]]]


@children[nodes;options]
# Извлекает детей.

$options[^hash::create[$options]]

$result[^table::sql{
	SELECT node_id, ancestor_id, distance
	FROM $self.refs_table
	WHERE 1
		AND ancestor_id IN (^self._list[$nodes;node_id])
		AND distance = 1
}[^self._sqlOptions[$options]]]


# nodes

@nodes[nodes;node_field;options]
# Извлекает узлы.

$options[^hash::create[$options]]

^if(!def $node_field){
	$node_field[node_id]
}
$hash_by[$options.hash-by]

$result[^table::sql{
	SELECT
		^self.node_fields.foreach[field;alias]{n.`$field`^if(def $alias){ AS '$alias'}}[, ]
		^self._parentField(true)
	FROM $self.nodes_table AS n
	JOIN $self.refs_table AS p ON (p.node_id = n.id AND p.distance = 1)
	WHERE n.id IN (^self._list[$nodes;$node_field])
	^if(def $self.order_field){ORDER BY $self.order_field}
}[^self._sqlOptions[$options]]]

^if(def $hash_by){
	$result[^result.hash[$hash_by][
		$.distinct(true)
		$.type[table]
	]]
}


# privates

@_parentField[with_parent]
$result[^if($with_parent){, p.ancestor_id AS parent_id}]


@_parentTable[with_parent]
$result[^if($with_parent){JOIN $self.refs_table AS p ON (p.node_id = t.node_id AND p.distance = 1)}]


@_link[nodes;to_nodes;options]
# Генерирует связи между указанными узлами.

$result[]

$options[^hash::create[$options]]
$refs[^table::create{node_id	ancestor_id	distance}]

^nodes.foreach[;node]{
	^to_nodes.foreach[;to_node]{
		^refs.append{$node.node_id	$to_node.ancestor_id	^eval($node.distance + $to_node.distance + 1)}
	}
}

^if(^options.[with-self].bool(false)){
	^nodes.foreach[;node]{
		^refs.append{$node.node_id	$node.node_id	0}
	}
}

^self._inserLinks[$refs]


@_unlink[nodes;to_nodes;options]
# Удаляет связи между указанными узлами или все связи указанного узла.

$options[^hash::create[$options]]

^if(def $to_nodes){
	^self._deleteLinks[
		node_id IN (^self._list[$nodes;node_id])
		AND ancestor_id IN (^self._list[$to_nodes;ancestor_id])
		^if(!^options.[with-self].bool(true)){AND distance > 0}
	]
}{
	^self._deleteLinks[
		node_id IN (^self._list[$nodes;node_id])
		OR ancestor_id IN (^self._list[$nodes;node_id])
	]
}


@_transaction[code]
# Транзакция.

^void:sql{BEGIN}

^try{
	$code

	^void:sql{COMMIT}
}{
	^void:sql{ROLLBACK}
}


@_inserLinks[links]
# Вставляет связи узлов.

$result[]

^void:sql{
	INSERT INTO $self.refs_table
	(node_id, ancestor_id, distance)
	VALUES
	^links.menu{
		($links.node_id, $links.ancestor_id, $links.distance)
	}[,]
}


@_deleteLinks[condition]
# Удаляет связи узлов.

$result[]

^if(def $condition){
	^void:sql{
		DELETE FROM $self.refs_table
		WHERE $condition
	}
}


@_insertNode[node]
# Вставляет узел.

$data[^node.intersection[$self.node_fields]]
^data.sub[
	$.id[]
]

^void:sql{
	INSERT INTO $self.nodes_table
	(^data.foreach[field;]{`$field`}[, ])
	VALUES
	(^data.foreach[;value]{'$value'}[, ])
}

$result(^int:sql{
	SELECT LAST_INSERT_ID()
}[
	$.default(0)
])


@_insertNodes[nodes]
# Вставляет набор узлов.

$result[]

$fields[$self.node_fields]

^void:sql{
	INSERT INTO $self.nodes_table
	(^fields.foreach[field;]{`$field`}[, ])
	VALUES
	^nodes.foreach[;node]{
		(^fields.foreach[field;]{'$node.$field'}[, ])
	}[,]
}


@_deleteNodes[nodes]
# Удаляет узлы.

$result[]

^if($nodes){
	^void:sql{
		DELETE FROM $self.nodes_table
		WHERE id IN (^nodes.menu{$nodes.node_id}[,])
	}
}


@_sqlOptions[options]
$result[^options.intersection[
	$.offset[]
	$.limit[]
]]


@_checkParentExist[parent_id;method]
$result[]

$parent[^self.descendants($parent_id)[
	$.limit(1)
]]

^if(!$parent){
	^throw[${self.CLASS_NAME}.$method;;no such parent node $parent_id]
}


@_list[nodes;field]
# Генерирует строковый список.

^switch[$nodes.CLASS_NAME]{
	^case[int;double;string;void]{
		$result[$nodes]
	}
	^case[table]{
		^if(!def $field){
			$columns[^nodes.columns[]]
			$field[$columns.column]
		}

		$result[^nodes.menu{$nodes.$field}[,]]
	}
	^case[hash]{
		^if(def $field){
			$result[^nodes.foreach[;node]{$node.$field}[,]]
		}{
			$result[^nodes.foreach[node;]{$node}[,]]
		}
	}
	^case[DEFAULT]{
		^throw[${self.CLASS_NAME}._list;;unsupported type $nodes.CLASS_NAME]
	}
}

^if(!def $result){
	$result[-1]
}