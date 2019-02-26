
DELIMITER $$$
DROP PROCEDURE IF EXISTS `parseSerializedProc`$$$
CREATE PROCEDURE `parseSerializedProc`(
	INOUT `input` text,
	IN `path` text,
	IN `delimiter` char(1),
	OUT `result` text)
NO SQL BEGIN
	declare _path_delim char(1) default '/';
	declare _path_key varchar(100);
	declare _path_next_key varchar(100);
	declare _input_key varchar(100);
	declare _key_locate varchar(100);
	declare _type varchar(100);
	declare _count int;
	declare _result text;

	set result = '';
	set _path_key = SUBSTRING_INDEX(path, _path_delim, 1);
	set _input_key = IF(LENGTH(_path_key)>0, CONCAT_WS(':', 's', LENGTH(_path_key), CONCAT('"', _path_key, '";')), '');
	set _key_locate = LOCATE(_input_key, input, 1);
	set input = IF(_key_locate>0, SUBSTRING(input, _key_locate + LENGTH(_input_key)), '');
	set _type = SUBSTRING(input, 1, 2);

	if _type = 's:' then
		set result = SUBSTRING_INDEX(SUBSTRING_INDEX(input, '";', 1), ':"', -1);
	end if;

	if _type = 'i:' then
		set result = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ';', 1), ':', -1);
	end if;

	if _type = 'b:' then
		set result = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ';', 1), ':', -1);
	end if;

	if _type = 'N;' then
		set result = 'NULL';
	end if;

	if _type = 'a:' then
		set _count = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ':', 2), ':', -1);
		set _path_next_key = SUBSTRING(path, LENGTH(_path_key) + LENGTH(_path_delim) + 1);
		set input = IF(LENGTH(_path_next_key)=0, CONCAT(';', input), input);

		while _count > 0 do
			if LENGTH(_path_next_key) = 0 then
				set input = SUBSTRING(input, LENGTH(SUBSTRING_INDEX(input, ';', 2)) + 2);
			end if;
			call parseSerializedProc(input, _path_next_key, delimiter, _result);
			if _result is not null then
				set result = CONCAT(result, delimiter, _result);
			end if;
			set _count = _count - 1;
		end while;
	end if;
	set result = TRIM(BOTH delimiter FROM result);
END$$$

DROP FUNCTION IF EXISTS `parseSerialized`$$$
CREATE FUNCTION `parseSerialized`(
	`input` text,
	`path` text,
	`delimiter` char(1))
RETURNS text NO SQL
BEGIN
	declare _result text;
	set @@session.max_sp_recursion_depth = 100;

	call parseSerializedProc(input, path, delimiter, _result);
	return _result;
END$$$
DELIMITER ;
