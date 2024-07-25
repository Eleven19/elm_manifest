import eleven19/assertions
import eleven19/validation.{type Validation}
import gleam/result

pub opaque type Scope {
  Scope(String)
}

pub type ParseResult(value) =
  Validation(value, ParseError)

pub type ParseError {
  EmptyInput(msg: String)
  WhitespaceOnlyInput(msg: String)
  InvalidName(msg: String)
}

pub fn parse(input: String) -> ParseResult(Scope) {
  let validated =
    input
    |> validation.compose(is_non_empty(_), [
      is_not_whitespace_only(_),
      is_valid_identifier(_),
    ])
  use scope <- result.try(validated)
  Ok(Scope(scope))
}

fn is_non_empty(value: String) -> ParseResult(String) {
  assertions.is_non_empty(value, "scope") |> validation.map_error(EmptyInput)
}

fn is_not_whitespace_only(value: String) -> ParseResult(String) {
  assertions.is_not_whitespace_only(value, "scope")
  |> validation.map_error(WhitespaceOnlyInput)
}

fn is_valid_identifier(value: String) -> ParseResult(String) {
  assertions.is_valid_identifier(value, "scope")
  |> validation.map_error(InvalidName)
}
