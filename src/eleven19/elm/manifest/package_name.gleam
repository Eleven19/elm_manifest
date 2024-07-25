import eleven19/assertions
import eleven19/validation.{type Validation}
import gleam/result

pub opaque type PackageName {
  PackageName(String)
}

pub type ParseError {
  EmptyInput(msg: String)
  WhitespaceOnlyInput(msg: String)
  InvalidName(msg: String)
}

pub type ParseResult(value) =
  Validation(value, ParseError)

pub fn parse(input: String) -> ParseResult(PackageName) {
  let validated =
    input
    |> validation.compose(is_non_empty(_), [
      is_not_whitespace_only(_),
      is_valid_identifier(_),
    ])

  use name <- result.try(validated)
  Ok(PackageName(name))
}

pub fn value(name: PackageName) -> String {
  let PackageName(value) = name
  value
}

fn is_non_empty(value: String) -> ParseResult(String) {
  assertions.is_non_empty(value, "name") |> validation.map_error(EmptyInput)
}

fn is_not_whitespace_only(value: String) -> ParseResult(String) {
  assertions.is_not_whitespace_only(value, "name")
  |> validation.map_error(WhitespaceOnlyInput)
}

fn is_valid_identifier(value: String) -> ParseResult(String) {
  assertions.is_valid_identifier(value, "name")
  |> validation.map_error(InvalidName)
}

pub fn package_name_equals_string(name: PackageName, compare_to: String) -> Bool {
  value(name) == compare_to
}
