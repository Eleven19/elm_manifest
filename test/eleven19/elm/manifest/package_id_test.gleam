import eleven19/elm/manifest/package_name
import gleeunit/should

pub fn parse_package_name_test() {
  "gleam_stdlib"
  |> package_name.parse
  |> should.be_ok
  |> package_name.value
  |> should.equal("gleam_stdlib")
}
