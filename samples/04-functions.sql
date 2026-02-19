-- =============================================
-- Built-in functions: all categories
-- =============================================

-- Support constants (no parens needed)
SELECT
  current_catalog,
  current_date,
  current_role,
  current_schema,
  current_time,
  current_timestamp,
  current_user,
  localtime,
  localtimestamp,
  session_user;

-- ---- Conditional ----
SELECT
  coalesce(NULL, NULL, 'fallback'),
  nullif(1, 1),
  greatest(1, 2, 3, 4, 5),
  least(10, 20, 5, 30);

-- ---- Aggregate functions ----
SELECT
  any_value(name),
  array_agg(DISTINCT name ORDER BY name),
  avg(salary),
  bit_and(flags),
  bit_or(flags),
  bit_xor(flags),
  bool_and(is_active),
  bool_or(is_admin),
  count(*),
  count(DISTINCT department_id),
  every(is_active),
  json_agg(name),
  jsonb_agg(name),
  json_object_agg(key, value),
  jsonb_object_agg(key, value),
  max(salary),
  min(salary),
  range_agg(schedule),
  range_intersect_agg(availability),
  string_agg(name, ', ' ORDER BY name),
  sum(quantity),
  xmlagg(data)
FROM employees;

-- Statistical aggregates
SELECT
  corr(height, weight),
  covar_pop(height, weight),
  covar_samp(height, weight),
  regr_avgx(salary, experience),
  regr_avgy(salary, experience),
  regr_count(salary, experience),
  regr_intercept(salary, experience),
  regr_r2(salary, experience),
  regr_slope(salary, experience),
  regr_sxx(salary, experience),
  regr_sxy(salary, experience),
  regr_syy(salary, experience),
  stddev(salary),
  stddev_pop(salary),
  stddev_samp(salary),
  variance(salary),
  var_pop(salary),
  var_samp(salary)
FROM measurements;

-- ---- String functions ----
SELECT
  ascii('A'),
  btrim('  hello  '),
  char_length('hello'),
  character_length('hello'),
  chr(65),
  concat('hello', ' ', 'world'),
  concat_ws(', ', 'a', 'b', 'c'),
  format('Hello %s, you are %s', 'world', 'great'),
  initcap('hello world'),
  left('hello', 3),
  length('hello'),
  lower('HELLO'),
  lpad('42', 5, '0'),
  ltrim('  hello'),
  md5('password'),
  normalize('hello', NFC),
  octet_length('hello'),
  overlay('hello' PLACING 'XX' FROM 2 FOR 3),
  parse_ident('schema.table'),
  position('lo' IN 'hello'),
  quote_ident('my table'),
  quote_literal('it''s'),
  quote_nullable(NULL),
  repeat('ha', 3),
  replace('hello world', 'world', 'pg'),
  reverse('hello'),
  right('hello', 3),
  rpad('hello', 10, '.'),
  rtrim('hello   '),
  split_part('a.b.c', '.', 2),
  starts_with('hello', 'hel'),
  strpos('hello', 'llo'),
  substr('hello', 2, 3),
  substring('hello' FROM 2 FOR 3),
  to_ascii('hello'),
  to_hex(255),
  translate('hello', 'helo', 'HELO'),
  trim(BOTH ' ' FROM '  hello  '),
  trim(LEADING FROM '  hello'),
  trim(TRAILING FROM 'hello  '),
  upper('hello'),
  unistr('\0041'),
  unicode_assigned(65);

-- Regexp functions
SELECT
  regexp_count('hello world hello', 'hello'),
  regexp_instr('hello world', 'world'),
  regexp_like('hello', '^h'),
  regexp_match('abc-123', '(\d+)'),
  regexp_matches('abc 123 def 456', '(\d+)', 'g'),
  regexp_replace('hello world', 'world', 'pg'),
  regexp_split_to_array('one,two,three', ','),
  regexp_split_to_table('one,two,three', ','),
  regexp_substr('abc-123-def', '\d+');

SELECT
  string_to_array('a,b,c', ','),
  string_to_table('abc', NULL),
  array_to_string(ARRAY['a','b','c'], ', ');

-- casefold (PG18)
SELECT casefold('Straße') = casefold('STRASSE') AS eq;

-- ---- Math functions ----
SELECT
  abs(-42),
  cbrt(27),
  ceil(4.2),
  ceiling(4.2),
  degrees(pi()),
  div(17, 5),
  exp(1),
  factorial(5),
  floor(4.8),
  gcd(12, 8),
  lcm(4, 6),
  ln(2.718),
  log(100),
  log10(1000),
  min_scale(1.00),
  mod(17, 5),
  pi(),
  power(2, 10),
  radians(180),
  random(),
  random_normal(0, 1),
  round(4.567, 2),
  scale(1.230),
  sign(-42),
  sqrt(144),
  setseed(0.42),
  trim_scale(1.200),
  trunc(4.567, 2),
  width_bucket(5.0, 0.0, 10.0, 5);

-- Gamma functions (PG18)
SELECT gamma(5.0), lgamma(100.0);

-- Trig functions
SELECT
  acos(0.5), acosd(0.5), asin(0.5), asind(0.5),
  atan(1), atand(1), atan2(1, 1), atan2d(1, 1),
  cos(0), cosd(0), cot(1), cotd(45),
  sin(0), sind(0), tan(0), tand(0),
  sinh(1), cosh(1), tanh(0.5),
  asinh(1), acosh(1.5), atanh(0.5);

-- ---- Date/Time functions ----
SELECT
  age(TIMESTAMP '2024-01-01', TIMESTAMP '2020-06-15'),
  clock_timestamp(),
  date_add(DATE '2024-01-01', INTERVAL '1 month'),
  date_bin(INTERVAL '15 minutes', now(), TIMESTAMP '2024-01-01'),
  date_part('year', now()),
  date_subtract(DATE '2024-12-31', INTERVAL '1 month'),
  date_trunc('month', now()),
  extract(EPOCH FROM now()),
  isfinite(DATE '2024-01-01'),
  justify_days(INTERVAL '35 days'),
  justify_hours(INTERVAL '30 hours'),
  justify_interval(INTERVAL '1 month 35 days 30 hours'),
  make_date(2024, 6, 15),
  make_interval(years => 1, months => 2),
  make_time(10, 30, 0),
  make_timestamp(2024, 6, 15, 10, 30, 0),
  make_timestamptz(2024, 6, 15, 10, 30, 0, 'UTC'),
  now(),
  statement_timestamp(),
  timeofday(),
  to_timestamp(1700000000),
  transaction_timestamp(),
  timezone('UTC', now());

SELECT pg_sleep(0.1);
SELECT pg_sleep_for(INTERVAL '100 milliseconds');
SELECT pg_sleep_until(now() + INTERVAL '1 second');

-- ---- Formatting functions ----
SELECT
  to_char(now(), 'YYYY-MM-DD HH24:MI:SS'),
  to_char(1234567.89, '9,999,999.99'),
  to_date('2024-01-15', 'YYYY-MM-DD'),
  to_number('1,234.56', '9G999D99'),
  to_timestamp('2024-01-15 10:30', 'YYYY-MM-DD HH24:MI');

-- ---- JSON functions ----
SELECT
  to_json('hello'::TEXT),
  to_jsonb(42),
  array_to_json(ARRAY[1, 2, 3]),
  row_to_json(ROW(1, 'hello')),
  json_build_array(1, 2, 'three'),
  jsonb_build_array(1, 2, 'three'),
  json_build_object('key', 'value', 'num', 42),
  jsonb_build_object('key', 'value'),
  json_object('{a,1,b,2}'),
  jsonb_object('{a,1,b,2}');

SELECT
  json_array_elements('[1,2,3]'::JSON),
  jsonb_array_elements('[1,2,3]'::JSONB),
  json_array_elements_text('["a","b"]'::JSON),
  jsonb_array_elements_text('["a","b"]'::JSONB),
  json_array_length('[1,2,3]'::JSON),
  jsonb_array_length('[1,2,3]'::JSONB);

SELECT
  json_each('{"a":1,"b":2}'::JSON),
  jsonb_each('{"a":1,"b":2}'::JSONB),
  json_each_text('{"a":1}'::JSON),
  jsonb_each_text('{"a":1}'::JSONB),
  json_extract_path('{"a":{"b":1}}'::JSON, 'a', 'b'),
  jsonb_extract_path('{"a":{"b":1}}'::JSONB, 'a', 'b'),
  json_extract_path_text('{"a":1}'::JSON, 'a'),
  jsonb_extract_path_text('{"a":1}'::JSONB, 'a'),
  json_object_keys('{"a":1,"b":2}'::JSON),
  jsonb_object_keys('{"a":1}'::JSONB);

SELECT
  json_populate_record(NULL::pg_class, '{"relname":"test"}'::JSON),
  jsonb_populate_record(NULL::pg_class, '{"relname":"test"}'::JSONB);

SELECT * FROM json_to_record('{"a":1,"b":"hello"}'::JSON) AS x(a INT, b TEXT);
SELECT * FROM jsonb_to_record('{"a":1}'::JSONB) AS x(a INT);

SELECT
  jsonb_set('{"a":1}'::JSONB, '{b}', '2'),
  jsonb_set_lax('{"a":1}'::JSONB, '{b}', NULL),
  jsonb_insert('{"a":[1,2]}'::JSONB, '{a,0}', '0'),
  json_strip_nulls('{"a":1,"b":null}'::JSON),
  jsonb_strip_nulls('{"a":1,"b":null}'::JSONB),
  jsonb_pretty('{"a":1}'::JSONB),
  json_typeof('"hello"'::JSON),
  jsonb_typeof('123'::JSONB);

SELECT
  jsonb_path_exists('{"a":1}', '$.a'),
  jsonb_path_match('{"a":1}', '$.a == 1'),
  jsonb_path_query('{"a":[1,2,3]}', '$.a[*]'),
  jsonb_path_query_array('{"a":[1,2,3]}', '$.a[*]'),
  jsonb_path_query_first('{"a":[1,2,3]}', '$.a[*]');

-- ---- Array functions ----
SELECT
  array_append(ARRAY[1,2], 3),
  array_cat(ARRAY[1,2], ARRAY[3,4]),
  array_dims(ARRAY[[1,2],[3,4]]),
  array_fill(0, ARRAY[3,3]),
  array_length(ARRAY[1,2,3], 1),
  array_lower(ARRAY[1,2,3], 1),
  array_ndims(ARRAY[[1,2],[3,4]]),
  array_position(ARRAY['a','b','c'], 'b'),
  array_positions(ARRAY[1,2,1,3,1], 1),
  array_prepend(0, ARRAY[1,2,3]),
  array_remove(ARRAY[1,2,3,2], 2),
  array_replace(ARRAY[1,2,3], 2, 99),
  array_reverse(ARRAY[1,2,3]),
  array_sample(ARRAY[1,2,3,4,5], 3),
  array_shuffle(ARRAY[1,2,3,4,5]),
  array_sort(ARRAY[3,1,2]),
  array_to_string(ARRAY[1,2,3], ','),
  array_upper(ARRAY[1,2,3], 1),
  cardinality(ARRAY[1,2,3]),
  trim_array(ARRAY[1,2,3,4,5], 2),
  unnest(ARRAY[1,2,3]);

-- Set-returning functions
SELECT * FROM generate_series(1, 10);
SELECT * FROM generate_series('2024-01-01'::DATE, '2024-12-31'::DATE, '1 month'::INTERVAL);
SELECT * FROM generate_subscripts(ARRAY[10,20,30], 1);

-- ---- Sequence functions ----
SELECT nextval('my_seq');
SELECT currval('my_seq');
SELECT setval('my_seq', 100);
SELECT lastval();

-- ---- UUID functions ----
SELECT
  gen_random_uuid(),
  uuidv4(),
  uuidv7(),
  uuid_extract_timestamp('018e3d62-8400-7000-8000-000000000000'::UUID),
  uuid_extract_version('018e3d62-8400-7000-8000-000000000000'::UUID);

-- ---- Enum functions ----
SELECT
  enum_first(NULL::order_status),
  enum_last(NULL::order_status),
  enum_range(NULL::order_status);

-- ---- Range functions ----
SELECT
  lower('[1,10]'::INT4RANGE),
  upper('[1,10]'::INT4RANGE),
  isempty('empty'::INT4RANGE),
  lower_inc('[1,10]'::INT4RANGE),
  upper_inc('[1,10]'::INT4RANGE),
  lower_inf('(,10]'::INT4RANGE),
  upper_inf('[1,)'::INT4RANGE),
  range_merge('[1,5]'::INT4RANGE, '[3,10]'::INT4RANGE),
  multirange('[1,5]'::INT4RANGE);

-- ---- Network functions ----
SELECT
  abbrev('192.168.1.0/24'::INET),
  broadcast('192.168.1.0/24'::INET),
  family('192.168.1.1'::INET),
  host('192.168.1.1/24'::INET),
  hostmask('192.168.1.0/24'::INET),
  inet_merge('192.168.1.0/24'::INET, '192.168.2.0/24'::INET),
  inet_same_family('192.168.1.1'::INET, '::1'::INET),
  masklen('192.168.1.0/24'::INET),
  netmask('192.168.1.0/24'::INET),
  network('192.168.1.1/24'::INET),
  set_masklen('192.168.1.0/24'::INET, 16);

-- ---- Text search functions ----
SELECT
  to_tsvector('english', 'The quick brown fox'),
  to_tsquery('english', 'quick & fox'),
  plainto_tsquery('english', 'quick brown fox'),
  phraseto_tsquery('english', 'quick brown fox'),
  websearch_to_tsquery('english', '"quick fox" -lazy'),
  ts_headline('english', 'The quick brown fox jumps', to_tsquery('fox')),
  ts_rank(to_tsvector('quick fox'), to_tsquery('fox')),
  ts_rank_cd(to_tsvector('quick fox'), to_tsquery('fox'));

SELECT
  array_to_tsvector(ARRAY['quick', 'fox']),
  get_current_ts_config(),
  numnode(to_tsquery('a & b | c')),
  querytree(to_tsquery('a & !b')),
  setweight(to_tsvector('hello'), 'A'),
  strip(to_tsvector('hello world')),
  tsvector_to_array(to_tsvector('hello world')),
  tsquery_phrase(to_tsquery('quick'), to_tsquery('fox'));

-- ---- Binary / Hash functions ----
SELECT
  bit_count('\xff'::BYTEA),
  bit_length('\xff'::BYTEA),
  crc32('\x00'::BYTEA),
  crc32c('\x00'::BYTEA),
  get_bit('\xff'::BYTEA, 0),
  get_byte('\xff'::BYTEA, 0),
  sha224('hello'::BYTEA),
  sha256('hello'::BYTEA),
  sha384('hello'::BYTEA),
  sha512('hello'::BYTEA),
  encode('\xff'::BYTEA, 'hex'),
  decode('ff', 'hex'),
  convert_from('\x48454c4c4f'::BYTEA, 'UTF8'),
  convert_to('hello', 'UTF8');

-- ---- XML functions ----
SELECT
  xmlcomment('a comment'),
  xmlconcat('<a/>'::XML, '<b/>'::XML),
  xmlelement(NAME "div", xmlattributes('bold' AS style), 'content'),
  xmlforest('John' AS first_name, 'Doe' AS last_name),
  xmlpi(NAME php, 'echo "hi"'),
  xmlroot('<a/>'::XML, VERSION '1.0'),
  xmltext('hello & world'),
  xmlexists('//a' PASSING CAST('<a/>' AS XML)),
  xml_is_well_formed('<a/>'),
  xml_is_well_formed_document('<a/>'),
  xml_is_well_formed_content('text'),
  xpath('/a', '<a>1</a>'::XML),
  xpath_exists('/a', '<a/>'::XML);

-- ---- Comparison / Utility ----
SELECT
  num_nonnulls(1, NULL, 3, NULL, 5),
  num_nulls(1, NULL, 3, NULL, 5);

-- ---- Common admin functions ----
SELECT
  current_setting('work_mem'),
  version(),
  pg_typeof(42),
  pg_backend_pid(),
  pg_database_size('mydb'),
  pg_table_size('users'),
  pg_total_relation_size('users'),
  pg_indexes_size('users'),
  pg_size_pretty(pg_total_relation_size('users')),
  pg_size_bytes('1 GB'),
  pg_relation_size('users'),
  pg_column_size(42),
  pg_column_compression('hello'::TEXT),
  format_type(23, -1),
  pg_get_viewdef('my_view'::REGCLASS),
  pg_get_indexdef('my_idx'::REGCLASS),
  col_description('users'::REGCLASS, 1),
  obj_description('users'::REGCLASS),
  pg_input_is_valid('42', 'integer'),
  pg_get_keywords();

SELECT set_config('work_mem', '256MB', false);

-- PG18 system functions
SELECT pg_numa_available();
SELECT * FROM pg_get_loaded_modules();
SELECT has_largeobject_privilege(16384, 'SELECT');

-- ---- Geometry functions ----
SELECT
  area(circle '((0,0),5)'),
  center(circle '((1,2),3)'),
  diameter(circle '((0,0),5)'),
  height(box '((0,0),(3,4))'),
  isclosed(path '((0,0),(1,1),(2,0))'),
  isopen(path '[(0,0),(1,1)]'),
  length(path '[(0,0),(3,4)]'),
  npoints(path '((0,0),(1,1),(2,0))'),
  pclose(path '[(0,0),(1,1),(2,0)]'),
  popen(path '((0,0),(1,1),(2,0))'),
  radius(circle '((0,0),5)'),
  slope(point '(0,0)', point '(3,4)'),
  width(box '((0,0),(3,4))'),
  bound_box(box '((0,0),(1,1))', box '((2,2),(3,3))');
