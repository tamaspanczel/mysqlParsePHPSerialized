
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
	declare _input_key varchar(100);
	declare _type varchar(100);
	declare _count int;
	declare _result text;

	set result = '';
	set _path_key = SUBSTRING_INDEX(path, _path_delim, 1);
	set _input_key = CONCAT_WS(":", "s", LENGTH(_path_key), CONCAT('"', _path_key, '";'));
	set input = SUBSTRING(input, LOCATE(_input_key, input, 1) + LENGTH(_input_key));
	set _type = SUBSTRING(input, 1, 1);

	if _type = 's' then
		set result = SUBSTRING_INDEX(SUBSTRING_INDEX(input, '";', 1), ':"', -1);
	end if;

	if _type = 'i' then
		set result = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ';', 1), ':', -1);
	end if;

	if _type = 'b' then
		set result = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ';', 1), ':', -1);
	end if;

	if _type = 'a' then
		set _count = SUBSTRING_INDEX(SUBSTRING_INDEX(input, ':', 2), ':', -1);
		while _count > 0 do
			call parseSerializedProc(input, SUBSTRING(path, LENGTH(_path_key) + LENGTH(_path_delim) + 1), delimiter, _result);
			set result = CONCAT(result, delimiter, _result);
			set _count = _count - 1;
		end while;
		set result = SUBSTRING(result, 2);
	end if;
END$$$

DROP FUNCTION IF EXISTS `parseSerialized`$$$
CREATE FUNCTION `parseSerialized`(
	`input` text,
	`path` text,
	`delimiter` char(1))
RETURNS text NO SQL
BEGIN
	declare _result text;

	call parseSerializedProc(input, path, delimiter, _result);
	return _result;
END$$$
DELIMITER ;
