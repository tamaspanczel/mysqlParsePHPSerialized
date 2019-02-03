parseSerialized
===============

MySql stored function to retrieve PHP serialized data on fly.

### Arguments
- `input` : php serialized data string
- `path`  : path to properties to get, use `/` to nested key
- `delimiter` : array properties result separator

### Example
input sample:
```json
{
  "tag": "value",
  "array": [{
    "key": "value1"
  },{
    "key": "value2"
  }]
}
```
select one tag:
```
select parseSerialized('a:2:{s:3:"tag";s:5:"value";s:5:"array";a:2:{i:0;a:1:{s:3:"key";s:6:"value1";}i:1;a:1:{s:3:"key";s:6:"value2";}}}', 'tag', ';')
```
select multiple tags / array:
```
set max_sp_recursion_depth = 3;
select parseSerialized('a:2:{s:3:"tag";s:5:"value";s:5:"array";a:2:{i:0;a:1:{s:3:"key";s:6:"value1";}i:1;a:1:{s:3:"key";s:6:"value2";}}}', 'array/key', ';')
```
