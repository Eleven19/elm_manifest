import eleven19/elm/manifest/package_name
import eleven19/elm/manifest/scope
import gleam/result
import gleam/string
import non_empty_list.{type NonEmptyList}

pub type PackageId {
  ScopedPackageId(scope: Scope, name: PackageName)
  UnscopedPackageId(name: PackageName)
}

pub type PackageName =
  package_name.PackageName

pub type Scope =
  scope.Scope

pub type ParseError {
  InvalidPackageId(message: String, input: String)
  InvalidScope(errors: NonEmptyList(scope.ParseError))
  InvalidPackageName(reasons: NonEmptyList(package_name.ParseError))
  Many(first: ParseError, rest: List(ParseError))
}

pub fn parse(input: String) -> Result(PackageId, ParseError) {
  let parts = string.split(input, on: "/")
  case parts {
    [name] -> {
      let name_result =
        package_name.parse(name) |> result.map_error(InvalidPackageName)
      use valid_name <- result.try(name_result)
      Ok(UnscopedPackageId(valid_name))
    }
    [given_scope, name] -> {
      let scope_result =
        scope.parse(given_scope) |> result.map_error(InvalidScope)
      let name_result =
        package_name.parse(name) |> result.map_error(InvalidPackageName)

      use valid_scope <- result.try(scope_result)
      use valid_name <- result.try(name_result)
      Ok(ScopedPackageId(valid_scope, valid_name))
    }
    _ -> Error(InvalidPackageId("Invalid package id", input))
  }
}
