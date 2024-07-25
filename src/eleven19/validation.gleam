//
// This module was derived from the `validate_monadic` package by Anthony Bradley.
// The original source code can be found at: https://github.com/abradley2/gleam-validate/blob/ae20b6fe8d974ea83b6ea4faae9d56745d1453be/src/validate_monadic.gleam

// The software was original licensed using the ISC license as follows:
// 
// Copyright (c) 2024 Anthony Bradley

// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.

// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
// REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
// INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
// LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
// OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
// PERFORMANCE OF THIS SOFTWARE.

import gleam/list
import gleam/result
import non_empty_list.{type NonEmptyList, NonEmptyList}

pub type Validation(validated, error) =
  Result(validated, NonEmptyList(error))

/// A convenience function for lifting a single error into our non-empty list of errors.
pub fn fail(error: error) -> Validation(value, error) {
  Error(non_empty_list.new(error, []))
}

/// A convience function for lifting a value into our validation type's `Ok` variant.
pub fn succeed(value: value) -> Validation(value, error) {
  Ok(value)
}

pub fn map(
  over validation: Validation(a, error),
  with map_fn: fn(a) -> b,
) -> Validation(b, error) {
  result.map(validation, map_fn)
}

pub fn map_error(
  over validation: Validation(a, error_a),
  with map_fn: fn(error_a) -> error_b,
) -> Validation(a, error_b) {
  case validation {
    Ok(v) -> Ok(v)
    Error(NonEmptyList(head, rest)) -> {
      Error(NonEmptyList(map_fn(head), list.map(rest, map_fn)))
    }
  }
}

pub fn compose(
  input: a,
  validation: fn(a) -> Validation(b, error),
  validations: List(fn(a) -> Validation(b, error)),
) -> Validation(b, error) {
  list.fold(validations, validation(input), fn(acc, cur) {
    and_also(acc, cur(input))
  })
}

pub fn and_also(
  validation_a: Validation(a, error),
  validation_b: Validation(a, error),
) -> Validation(a, error) {
  case validation_a, validation_b {
    Ok(_), Ok(a) -> Ok(a)
    Error(NonEmptyList(err_a_head, err_a_rest)),
      Error(NonEmptyList(err_b_head, err_b_rest))
    -> {
      Error(NonEmptyList(
        err_a_head,
        list.concat([err_a_rest, list.prepend(err_b_rest, err_b_head)]),
      ))
    }
    Error(err), _ -> Error(err)
    _, Error(err) -> Error(err)
  }
}

pub fn and_then(
  over validation: Validation(a, error),
  bind bind_fn: fn(a) -> Validation(b, error),
) -> Validation(b, error) {
  result.then(validation, bind_fn)
}

pub fn and_map(
  prev prev_validation: Validation(fn(a) -> b, error),
  next validation: Validation(a, error),
) -> Validation(b, error) {
  case prev_validation {
    Ok(apply) -> {
      case validation {
        Ok(a) -> Ok(apply(a))
        Error(err) -> Error(err)
      }
    }
    Error(NonEmptyList(prev_err_head, prev_err_rest)) -> {
      case validation {
        Ok(_) -> {
          Error(NonEmptyList(prev_err_head, prev_err_rest))
        }
        Error(NonEmptyList(next_err_head, next_err_rest)) -> {
          Error(NonEmptyList(
            prev_err_head,
            list.flatten([
              prev_err_rest,
              list.prepend(next_err_rest, next_err_head),
            ]),
          ))
        }
      }
    }
  }
}
