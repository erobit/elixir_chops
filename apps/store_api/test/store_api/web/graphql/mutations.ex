defmodule StoreAPI.Graphql.Mutations do
  @login """
    mutation Employee($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        token
      }
    }
  """

  @edit_employee """
    mutation CreateEmployee(
      $email: String!,
      $phone: String!,
      $role: String!,
      $locations: [Int]!
    ) {
      employee(email: $email, phone: $phone, password: "password", role: $role, is_active: true, locations: $locations) {
        phone
      }
    }
  """

  def login, do: @login
  def edit_employee, do: @edit_employee
end
