import eleven19/validation.{type Validation}
import gleam/regex
import gleam/string

pub fn is_non_empty(value: String, source: String) -> Validation(String, String) {
  case string.is_empty(value) {
    False -> validation.succeed(value)
    True -> validation.fail(source <> " is empty")
  }
}

pub fn is_not_whitespace_only(
  value: String,
  source: String,
) -> Validation(String, String) {
  case string.is_empty(string.trim(value)) {
    False -> validation.succeed(value)
    True -> validation.fail(source <> " consists only of whitespace characters")
  }
}

pub fn is_valid_identifier(
  value: String,
  source: String,
) -> Validation(String, String) {
  let options = regex.Options(case_insensitive: False, multi_line: False)
  let assert Ok(identifier_regex) =
    regex.compile("^([a-z][a-z0-9_]+)$", options)
  case regex.check(with: identifier_regex, content: value) {
    True -> validation.succeed(value)
    False -> validation.fail(source <> " is not a valid identifier")
  }
}
