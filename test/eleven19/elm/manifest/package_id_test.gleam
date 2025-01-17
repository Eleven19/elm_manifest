import eleven19/elm/manifest/package_name
import non_empty_list
import startest/expect

pub fn parse_package_name_test() {
  "gleam_stdlib"
  |> package_name.parse
  |> expect.to_be_ok
  |> package_name.value
  |> expect.to_equal("gleam_stdlib")
}

pub fn parse_package_name_empty_input_test() {
  ""
  |> package_name.parse
  |> expect.to_be_error
  |> non_empty_list.to_list
  |> expect.list_to_contain(package_name.EmptyInput("name is empty"))
}

pub fn parse_package_name_whitespace_only_input_test() {
  " "
  |> package_name.parse
  |> expect.to_be_error
  |> non_empty_list.to_list
  |> expect.list_to_contain(package_name.WhitespaceOnlyInput(
    "name consists only of whitespace characters",
  ))
}

pub fn parse_package_name_invalid_name_test() {
  "gleam-stdlib"
  |> package_name.parse
  |> expect.to_be_error
  |> non_empty_list.to_list
  |> expect.list_to_contain(package_name.InvalidName(
    "name is not a valid identifier",
  ))
}
