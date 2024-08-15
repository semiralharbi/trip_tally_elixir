# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TripTally.Repo.insert!(%TripTally.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias TripTally.Expenses.Expense
alias TripTally.Repo
alias TripTally.Accounts.User
alias TripTally.Trips.Locations
alias TripTally.Trips.Trips

# Users
user1 =
  Repo.get_by(User, email: "user@example.com") ||
    %User{email: "user1@example.com", hashed_password: "Password2@"} |> Repo.insert!()

user2 =
  Repo.get_by(User, email: "user@example.com") ||
    %User{email: "user2@example.com", hashed_password: "Password2@"} |> Repo.insert!()

# Locations
location1 =
  %Locations{country_code: "US", city_name: "New York", user_id: user1.id}
  |> Locations.changeset(%{})
  |> Repo.insert!()

location2 =
  %Locations{country_code: "FR", city_name: "Paris", user_id: user2.id}
  |> Locations.changeset(%{})
  |> Repo.insert!()

# Trips
trip1 =
  %Trips{
    transport_type: "Plane",
    planned_cost: 1200.0,
    date_from: ~D[2024-04-01],
    date_to: ~D[2024-04-10],
    location_id: location1.id,
    user_id: user1.id
  }
  |> Trips.changeset(%{})
  |> Repo.insert!()

_trip2 =
  %Trips{
    transport_type: "Train",
    planned_cost: 300.0,
    date_from: ~D[2024-05-15],
    date_to: ~D[2024-05-20],
    location_id: location2.id,
    user_id: user2.id
  }
  |> Trips.changeset(%{})
  |> Repo.insert!()

# Expenses for trip1
%Expense{
  name: "Hotel Stay",
  date: ~D[2024-04-02],
  price: Money.new(450_00, :USD),
  trip_id: trip1.id,
  user_id: user1.id
}
|> Expense.changeset(%{})
|> Repo.insert!()

%Expense{
  name: "Flight Meal",
  date: ~D[2024-04-01],
  price: Money.new(50_00, :USD),
  trip_id: trip1.id,
  user_id: user1.id
}
|> Expense.changeset(%{})
|> Repo.insert!()

%Expense{
  name: "Museum Tickets",
  date: ~D[2024-04-05],
  price: Money.new(30_00, :USD),
  trip_id: trip1.id,
  user_id: user1.id
}
|> Expense.changeset(%{})
|> Repo.insert!()
